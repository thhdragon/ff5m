#!/bin/bash

## Mod's uninstall script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

set -x

revert_klipper_patches() {
    local SRC_DIR="/opt/config/mod/.py/klipper"
    local TARGET_DIR="/opt/klipper/klippy"
    
    # Klipper extensions
    echo "Remove klipper plugins: "
    echo $SRC_DIR/plugins/*
    echo
    
    find $SRC_DIR/plugins/ -type f | while read -r file; do
        local rel_file=${file#"$SRC_DIR/plugins/"}
        
        rm -f "$TARGET_DIR/extras/$rel_file"
    done
    
    # Klipper patches
    find $SRC_DIR/patches -type f | while read -r file; do
        local rel_file=${file#"$SRC_DIR/patches/"}
        local target="$TARGET_DIR/$rel_file"
        
        if [ -f "$target.bak" ]; then
            echo "Restore klipper backup: $target"
            mv -f "$target.bak" "$target"
        fi
    done
}

uninstall() {
    chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
        --mode restore \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.cfg/restore.cfg
    
    chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
        --mode restore \
        --config /opt/config/printer.base.cfg \
        --params /opt/config/mod/.cfg/restore.base.cfg \
        --data /opt/config/mod/.cfg/data.restore.base.cfg
    
    grep -q qvs.qiniuapi.com /etc/hosts && sed -i '|qvs.qiniuapi.com|d' /etc/hosts
    # TODO: remove modified variable files ?
    grep -q ZLOAD_VARIABLE /opt/klipper/klippy/extras/save_variables.py && cp /opt/config/mod/.shell/save_variables.py.orig /opt/klipper/klippy/extras/save_variables.py
    
    revert_klipper_patches

    # Make sure to umount all mounted files
    # In case of accidentally run this script after init
    umount /data/.mod/.zmod/sys
    umount /data/.mod/.zmod/dev
    umount /data/.mod/.zmod/tmp
    umount /data/.mod/.zmod/opt/klipper
    umount /data/.mod/.zmod/opt/config
    umount /data/.mod/.zmod/data
    umount /data/.mod/.zmod/proc 
    umount /root/printer_data/scripts
    umount /root/printer_data/py
    umount /root/.oh-my-zsh
    
    rm -rf /data/.mod
    rm /etc/init.d/S00fix
    rm /etc/init.d/S00init
    rm /etc/init.d/S99moon
    rm /etc/init.d/S98camera
    rm /etc/init.d/S98zssh
    rm /etc/init.d/K99moon
    rm -rf /opt/config/mod/
    rm -rf /root/printer_data
    # REMOVE zsh
    rm -rf /root/.profile
    rm -rf /root/.zshrc
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
        rm -rf /opt/config/mod_data

        # Remove ROOT
        rm -rf /etc/init.d/S50sshd /etc/init.d/S55date /bin/dropbearmulti /bin/dropbear /bin/dropbearkey /bin/scp /etc/dropbear /etc/init.d/S60dropbear
        # Remove BEEP
        rm -f /usr/bin/audio /usr/lib/python3.7/site-packages/audio.py /usr/bin/audio_midi.sh /opt/klipper/klippy/extras/gcode_shell_command.py
        rm -rf /usr/lib/python3.7/site-packages/mido/
    fi
    
    sync
    reboot
    exit
}

uninstall "$1"  &> /data/logFiles/uninstall.log
