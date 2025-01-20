#!/bin/sh

## Mod's configuration preparation script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

set -x

fix_config() {
    echo "START fix_config"
    date

    TMP_CFG_PATH=/tmp/printer.tmp.cfg

    # Move parameters from printer.base.cfg to printer.cfg
    
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode backup \
        --config /opt/config/printer.base.cfg \
        --data $TMP_CFG_PATH \
        --params /opt/config/mod/.shell/cfg/init.move.cfg

    if [ $? -eq 0 ]; then
        DATA_MOVE_CFG=$TMP_CFG_PATH
        # TODO: Merge?
    else
        DATA_MOVE_CFG=/opt/config/mod/.shell/cfg/data.init.move.cfg
    fi

    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
            --mode restore --avoid_writes \
            --config /opt/config/printer.cfg \
            --data $DATA_MOVE_CFG \
            --params /opt/config/mod/.shell/cfg/init.move.cfg

    # Initialized printer.base.cfg to printer.cfg with custom configuration

    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.shell/cfg/init.cfg
        
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.base.cfg \
        --params /opt/config/mod/.shell/cfg/init.base.cfg \
        --data /opt/config/mod/.shell/cfg/data.init.base.cfg


    # Restore printer.baes.cfg if changed since backup
    if [ -f /opt/config/printer.base.cfg.bak ]; then
        chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
            --mode restore --avoid_writes \
            --config /opt/config/printer.base.cfg \
            --params /opt/config/mod_data/backup.params.cfg \
            --data /opt/config/printer.base.cfg.bak
    fi

    # (?) Restrict public unauthorized access to printer's camera (only SerialNnumber is needed)
    grep -q qvs.qiniuapi.com /etc/hosts || sed -i '2 i\127.0.0.1 qvs.qiniuapi.com' /etc/hosts

    # TODO: remove modified variable files ?
    grep -q ZLOAD_VARIABLE /opt/klipper/klippy/extras/save_variables.py || cp /opt/config/mod/.shell/save_variables.py /opt/klipper/klippy/extras/save_variables.py

    echo "END fix_config"
}

mkdir -p /opt/config/mod_data/log/
ln -s /opt/config/mod/.shell/fix_config.sh /etc/init.d/S00fix

mv /opt/config/mod_data/log/fix_config.log.4 /opt/config/mod_data/log/fix_config.log.5
mv /opt/config/mod_data/log/fix_config.log.3 /opt/config/mod_data/log/fix_config.log.4
mv /opt/config/mod_data/log/fix_config.log.2 /opt/config/mod_data/log/fix_config.log.3
mv /opt/config/mod_data/log/fix_config.log.1 /opt/config/mod_data/log/fix_config.log.2
mv /opt/config/mod_data/log/fix_config.log /opt/config/mod_data/log/fix_config.log.1

fix_config &>/opt/config/mod_data/log/fix_config.log

sync
