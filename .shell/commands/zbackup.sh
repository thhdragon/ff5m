#!/bin/bash

## Configuration backup and restore
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

CFG_PATH="/opt/config/mod_data/backup.params.cfg"

if [ ! -f $CFG_PATH ]; then
    cp "/opt/config/mod/.cfg/default/backup.params.cfg" "$CFG_PATH"
fi


PARAMS="-p ${CFG_PATH}"

tar_config() {
    local name="backup_$(date +%Y%m%d_%H%M%S)"

    pushd > /dev/null /opt/config || exit 1

    tar -cf "./mod_data/$name.tar"       \
        ./printer.cfg                    \
        ./printer.base.cfg               \
        ./printer.base.cfg.bak           \
        ./mod_data/backup.params.cfg     \
        ./mod_data/camera.conf           \
        ./mod_data/ssh.conf              \
        ./mod_data/ssh.key               \
        ./mod_data/ssh.pub.txt           \
        ./mod_data/user.cfg              \
        ./mod_data/user.moonraker.conf   \
        ./mod_data/variables.cfg         \
        ./mod_data/web.conf              \
    > /dev/null 2>&1

    gzip "./mod_data/$name.tar"
    rm -f "./mod_data/$name.tar"

    popd > /dev/null || true

    echo "Backup archive successfully created! You can download it from the Configuration tab:"
    echo "Configuration -> mod_data -> $name.tar.gz"
}


while [ "$#" -gt 0 ]; do
    param=$1; shift
    
    case "$param" in
        --backup)
            PARAMS="-m backup ${PARAMS}"
        ;;
        --restore)
            PARAMS="-m restore ${PARAMS} -w"
        ;;
        --verify)
            PARAMS="-m verify ${PARAMS}"
        ;;
        --tar-backup)
            tar_config
            exit $?
        ;;
        --dry)
            if [ "$1" -eq 1 ]; then
                PARAMS="${PARAMS} --dry"
            fi
            shift
        ;;
        --verbose)
            if [ "$1" -eq 1 ]; then
                PARAMS="${PARAMS} --verbose"
            fi
            shift
        ;;
        *)
            echo "Unknow parameter: '$1'"
            exit 1
        ;;
    esac
done

if [ "$2" = 1 ]; then PARAMS="$PARAMS --dry"; fi
if [ "$3" = 1 ]; then PARAMS="$PARAMS --verbose"; fi

# TODO: klipper sets LD_PRELOAD variable, idkw
LD_PRELOAD="" chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py $PARAMS
