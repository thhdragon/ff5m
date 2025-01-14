#!/bin/bash
#
# Switch to alternative mod version

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

/etc/init.d/S99moon stop
/etc/init.d/S99moon up

echo "Switching repository..."

umount /data/.mod/
RECOVER_RET=$(chroot /data/.mod/.zmod /bin/curl -X POST "http://localhost:7125/machine/update/recover?name=zmod&hard=true")

if [ $RECOVER_RET != "OK" ]; then
    echo "Unable to switch repository: $RECOVER_RET"
    exit 3
fi

# This message not printed, since /machine/update/recover reboots if succeed

echo "ZMOD source changed successfully!"
