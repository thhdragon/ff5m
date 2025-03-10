#!/bin/bash

## Script to switch zmod to alternative source
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

CURL=/opt/cloud/curl-*/bin/curl

echo "Download requirements..."

rm -rf /opt/packages
mkdir -p /opt/packages

cd /opt/packages || exit 2

$CURL -# -k -OL https://github.com/DrA1ex/mjpg-streamer/releases/download/v1.0.1/mjpg-streamer-input-uvc_1.0.1-1_armv7-3.2.ipk
$CURL -# -k -OL https://github.com/DrA1ex/mjpg-streamer/releases/download/v1.0.1/mjpg-streamer-output-http_1.0.1-1_armv7-3.2.ipk
$CURL -# -k -OL https://github.com/DrA1ex/mjpg-streamer/releases/download/v1.0.1/mjpg-streamer_1.0.1-1_armv7-3.2.ipk

OPKG=/opt/bin/opkg

$OPKG update \
    && $OPKG install \
        mjpg-streamer_1.0.1-1_armv7-3.2.ipk \
        mjpg-streamer-input-uvc_1.0.1-1_armv7-3.2.ipk \
        mjpg-streamer-output-http_1.0.1-1_armv7-3.2.ipk \
    && $OPKG install busybox htop nano zsh

if [ "$?" -ne 0 ]; then
  echo "Failed to install dependencies!"
  exit 1
fi

echo "Remove old repository data..."

rm -rf /opt/config/mod/.git
rm -rf /opt/config/.mod_repo_backup

sed -i '/\[update_manager zmod\]/,/^$/ {
  /origin:/ {
    s|: .*|: https://github.com/DrA1ex/ff5m.git|
    # Stop processing further matches in this address block
    b
  }
}' /opt/config/moonraker.conf
if [ $? -ne 0 ]; then echo "Unable to update moonraker.conf"; exit 1; fi

sync

sqlite3 /opt/config/mod_data/database/moonraker-sql.db \
"UPDATE namespace_store \
    SET value = json_set(value, \
        '$.upstream_url', 'https://github.com/DrA1ex/ff5m.git', \
        '$.recovery_url', 'https://github.com/DrA1ex/ff5m.git') \
WHERE namespace = 'update_manager' AND key = 'zmod';"

# sqlite3 /opt/config/mod_data/database/moonraker-sql.db \
#     "UPDATE namespace_store \
#     SET value = json_set(value, \
#         '$.upstream_url', 'https://github.com/DrA1ex/ff5m.git', \
#         '$.recovery_url', 'https://github.com/DrA1ex/ff5m.git', \
#         '$.git_branch', 'dev', \
#         '$.rollback_branch', 'dev',
#         '$.branches', json_array('main', 'dev')) \
#     WHERE namespace = 'update_manager' AND key = 'zmod';"

if [ $? -ne 0 ]; then echo "Unable to delete old repository information"; exit 2; fi

echo "Restarting Moonraker..."

/etc/init.d/S99moon stop &> /dev/null
/etc/init.d/S99moon up &> /dev/null

echo "Waiting moonraker to start..."

started=0
for _ in $(seq 0 30); do
    $CURL http://localhost:7125 &> /dev/null && started=1 && break
    sleep 1
done

if [ "$started" -eq 0 ]; then
  echo "Moonraker not started. Try again later"
  exit 2
fi

echo "Switching repository..."

RECOVER_RET=$($CURL -X POST "http://localhost:7125/machine/update/recover?name=zmod&hard=true" 2>/dev/null)

if [[ "$RECOVER_RET" != '{"result":"ok"}' ]]; then
    echo "Unable to switch repository: $RECOVER_RET"
    exit 3
fi

echo "ZMOD source changed successfully!"
echo; echo "Rebooting..."

reboot