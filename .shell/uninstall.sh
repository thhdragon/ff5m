#!/bin/bash

## Mod's uninstall script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

set -x

uninstall() {
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
    --mode restore \
    --config /opt/config/printer.cfg \
    --no_data \
    --params /opt/config/mod/.cfg/restore.cfg
    
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
    --mode restore \
    --config /opt/config/printer.base.cfg \
    --params /opt/config/mod/.cfg/restore.base.cfg \
    --data /opt/config/mod/.cfg/data.restore.base.cfg
    
    grep -q qvs.qiniuapi.com /etc/hosts && sed -i '|qvs.qiniuapi.com|d' /etc/hosts
    # TODO: remove modified variable files ?
    grep -q ZLOAD_VARIABLE /opt/klipper/klippy/extras/save_variables.py && cp /opt/config/mod/.shell/save_variables.py.orig /opt/klipper/klippy/extras/save_variables.py
    
    
    rm -rf /data/.mod
    rm /etc/init.d/S00fix
    rm /etc/init.d/S00init
    rm /etc/init.d/S99moon
    rm /etc/init.d/S98camera
    rm /etc/init.d/S98zssh
    rm /etc/init.d/K99moon
    rm -rf /opt/config/mod/
    # REMOVE SCRIPTS
    rm -rf /root/printer_data/scripts
    # REMOVE ENTWARE
    rm -rf /opt/bin
    rm -rf /opt/etc
    rm -rf /opt/home
    rm -rf /opt/lib
    rm -rf /opt/libexec
    rm -rf /opt/root
    rm -rf /opt/sbin
    rm -rf /opt/share
    rm -rf /opt/tmp
    rm -rf /opt/usr
    rm -rf /opt/var
    
    if [ ! "$1" != "--soft" ]; then
        # Remove ROOT
        rm -rf /etc/init.d/S50sshd /etc/init.d/S55date /bin/dropbearmulti /bin/dropbear /bin/dropbearkey /bin/scp /etc/dropbear /etc/init.d/S60dropbear
        # Remove BEEP
        rm -f /usr/bin/audio /usr/lib/python3.7/site-packages/audio.py /usr/bin/audio_midi.sh /opt/klipper/klippy/extras/gcode_shell_command.py
        rm -rf /usr/lib/python3.7/site-packages/mido/
    fi
    
    sync
    rm -f /opt/uninstall.sh

    sync
    reboot
    exit
}

uninstall "$1"  &> /data/logFiles/uninstall.log