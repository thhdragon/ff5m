#!/bin/sh

## Mod's preparationc script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

set -x

restore_base() {
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.shell/cfg/restore.cfg
        
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore \
        --config /opt/config/printer.base.cfg \
        --params /opt/config/mod/.shell/cfg/restore.base.cfg \
        --data /opt/config/mod/.shell/cfg/data.restore.base.cfg
    
    grep -q qvs.qiniuapi.com /etc/hosts && sed -i '|qvs.qiniuapi.com|d' /etc/hosts
    # TODO: remove modified variable files ?
    grep -q ZLOAD_VARIABLE /opt/klipper/klippy/extras/save_variables.py && cp /opt/config/mod/.shell/save_variables.py.orig /opt/klipper/klippy/extras/save_variables.py
    
    
    rm -rf /data/.mod
    rm /etc/init.d/S00fix
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
}

start_prepare() {
    renice -16 $(ps |grep klippy.py| grep -v grep| awk '{print $1}')
    
    if [ -f /opt/config/mod/REMOVE ]; then
        restore_base
        
        # Remove ROOT
        rm -rf /etc/init.d/S50sshd /etc/init.d/S55date /bin/dropbearmulti /bin/dropbear /bin/dropbearkey /bin/scp /etc/dropbear /etc/init.d/S60dropbear
        # Remove BEEP
        rm -f /usr/bin/audio /usr/lib/python3.7/site-packages/audio.py /usr/bin/audio_midi.sh /opt/klipper/klippy/extras/gcode_shell_command.py
        rm -rf /usr/lib/python3.7/site-packages/mido/
        
        sync
        rm -f /etc/init.d/prepare.sh
        sync
        reboot
        exit
    fi
    
    if [ -f /opt/config/mod/SOFT_REMOVE ]; then
        restore_base
        
        sync
        rm -f /etc/init.d/prepare.sh
        sync
        reboot
        exit
    fi
    
    if [ ! -f /etc/init.d/S00fix ]; then
        /opt/config/mod/.shell/fix_config.sh
        ln -s /opt/config/mod/.shell/fix_config.sh /etc/init.d/S00fix
    fi
    
    echo "System start" >/data/logFiles/ssh.log
    
    mount -t proc /proc $MOD/proc
    mount --rbind /sys $MOD/sys
    mount --rbind /dev $MOD/dev
    
    mount --bind /tmp $MOD/tmp
    
    mkdir -p $MOD/opt/config
    mount --bind /opt/config $MOD/opt/config
    
    mkdir -p $MOD/data
    mount --bind /data $MOD/data
    
    mount --bind /opt/klipper $MOD/opt/klipper
    
    mkdir -p $MOD/root/printer_data/misc
    mkdir -p $MOD/root/printer_data/tmp
    mkdir -p $MOD/root/printer_data/comms
    mkdir -p $MOD/root/printer_data/certs
    
    # oh-my-zsh
    mkdir -p /root/.oh-my-zsh
    mount --bind /opt/config/mod/.zsh/.oh-my-zsh /root/.oh-my-zsh
    ln -s /opt/config/mod/.zsh/.profile /root/.profile
    ln -s /opt/config/mod/.zsh/.zshrc /root/.zshrc
    
    
    GIT_BRANCH=$(chroot $MOD git --git-dir=/opt/config/mod/.git rev-parse --abbrev-ref HEAD)
    GIT_COMMIT_ID=$(chroot $MOD git --git-dir=/opt/config/mod/.git rev-parse --short HEAD)
    GIT_COMMIT_DATE=$(chroot $MOD git --git-dir=/opt/config/mod/.git show -s HEAD --format=%cd --date=format:'%d.%m.%Y %H:%M:%S')
    
    FIRMWARE_VERSION=$(cat /root/version)
    MOD_VERSION=$(cat /opt/config/mod/version.txt)
    PATCH_VERSION="$GIT_BRANCH-$GIT_COMMIT_ID @ $GIT_COMMIT_DATE"
    
    chroot $MOD /opt/config/mod/.shell/root/version.sh "$FIRMWARE_VERSION" "$MOD_VERSION" "$PATCH_VERSION"

    /opt/config/mod/.shell/motd.sh > /etc/motd
    
    if [ -f "/opt/config/mod_data/database/moonraker-sql.db" ]; then
        /opt/config/mod/.shell/migrate_db.sh
    fi
    
    /opt/config/mod/.shell/zshaper.sh --clear
    
    SWAP="/root/swap"
    chroot $MOD /opt/config/mod/.shell/root/start.sh "$SWAP" &
}

if [ -f /opt/config/mod/SKIP_ZMOD ]
then
    rm -f /opt/config/mod/SKIP_ZMOD
    md -p /data/lost+found
    mount --bind /data/lost+found /data/.mod
    exit 0
fi

while ! mount | grep /dev/mmcblk0p7; do sleep 1; done

mv /data/logFiles/zmod.log.4 /data/logFiles/zmod.log.5
mv /data/logFiles/zmod.log.3 /data/logFiles/zmod.log.4
mv /data/logFiles/zmod.log.2 /data/logFiles/zmod.log.3
mv /data/logFiles/zmod.log.1 /data/logFiles/zmod.log.2
mv /data/logFiles/zmod.log /data/logFiles/zmod.log.1

start_prepare &>/data/logFiles/zmod.log
