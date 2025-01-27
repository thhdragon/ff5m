#!/bin/sh

CFG_SCRIPT="/opt/config/mod/.shell/commands/zconf.sh"
CFG_PATH="/opt/config/mod_data/variables.cfg"

send_klipper() {
    $CFG_SCRIPT $CFG_PATH --set "md5_check_result=$1"
    echo "Done."
}

FILE_NAME=${1}
if [ -z "${FILE_NAME}" ]; then
    send_klipper 1
    exit 1
elif [ ! -f "${FILE_NAME}" ]; then
    send_klipper 2
    exit 2
fi

DELETE_FILE=${2}
if [ -z "${DELETE_FILE}" ]; then
  DELETE_FILE="false"
fi

ORIG_MD5="$(/usr/bin/awk -F: '/; MD5/{printf("%s", $2)}' "${FILE_NAME}"|/usr/bin/tr -d ' \r')"
if [ -z "${ORIG_MD5}" ]
    then
        send_klipper 3
        exit 3
fi

LOCAL_MD5="$(/bin/cat "${FILE_NAME}"|/bin/grep -v '^; MD5:'|/usr/bin/md5sum|/usr/bin/tr -d ' -')"

if [ "_${LOCAL_MD5}" = "_${ORIG_MD5}" ]
    then
        if grep -q 'G2 ' "${FILE_NAME}" || grep -q 'G3 ' "${FILE_NAME}"
            then
                send_klipper 4
            else
                send_klipper 5
        fi
else
    if [ "true" = "${DELETE_FILE}" ] || [ "True" = "${DELETE_FILE}" ]
        then
            /bin/rm -f "${FILE_NAME}"
                send_klipper 6
        else
                send_klipper 7
    fi
fi
exit 0
