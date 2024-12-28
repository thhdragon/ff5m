#!/bin/sh

set -x

start_prepare()
{
    MOD=/data/.mod/.zmod
    while ! mount |grep /dev/mmcblk0p7; do sleep 10; done

    if [ -f /opt/config/mod/REMOVE ]
     then
      rm -rf /data/.mod
      rm /etc/init.d/S99moon
      rm /etc/init.d/S98camera
      rm /etc/init.d/S98zssh
      rm /etc/init.d/K99moon
      rm -rf /opt/config/mod/
      grep -q 'include mod.user.cfg' /opt/config/printer.cfg && sed -i '|include mod.user.cfg|d' /opt/config/printer.cfg
      grep -q 'include ./mod/mod.cfg' /opt/config/printer.cfg && sed -i '|include ./mod/mod.cfg|d' /opt/config/printer.cfg
      grep -q 'include ./mod/display_off.cfg' /opt/config/printer.cfg && sed -i '|include ./mod/display_off.cfg|d' /opt/config/printer.cfg
      grep -q qvs.qiniuapi.com /etc/hosts && sed -i '|qvs.qiniuapi.com|d' /etc/hosts
      # Remove ROOT
      rm -rf /etc/init.d/S50sshd /etc/init.d/S55date /bin/dropbearmulti /bin/dropbear /bin/dropbearkey /bin/scp /etc/dropbear /etc/init.d/S60dropbear
      # Remove BEEP
      rm -f /usr/bin/audio /usr/lib/python3.7/site-packages/audio.py /usr/bin/audio_midi.sh /opt/klipper/klippy/extras/gcode_shell_command.py
      rm -rf /usr/lib/python3.7/site-packages/mido/
      # REMOVE SCRIPTS
      rm -rf /root/printer_data/scripts/
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

      sync
      rm -f /etc/init.d/prepare.sh
      sync
      reboot
      exit
    fi

    if [ -f /opt/config/mod/SOFT_REMOVE ]
     then
      rm -rf /data/.mod
      rm /etc/init.d/S99moon
      rm /etc/init.d/S98camera
      rm /etc/init.d/S98zssh
      rm /etc/init.d/K99moon
      rm -rf /opt/config/mod/
      grep -q 'include mod.user.cfg' /opt/config/printer.cfg && sed -i '|include mod.user.cfg|d' /opt/config/printer.cfg
      grep -q 'include ./mod/mod.cfg' /opt/config/printer.cfg && sed -i '|include ./mod/mod.cfg|d' /opt/config/printer.cfg
      grep -q 'include ./mod/display_off.cfg' /opt/config/printer.cfg && sed -i '|include ./mod/display_off.cfg|d' /opt/config/printer.cfg
      grep -q qvs.qiniuapi.com /etc/hosts && sed -i '|qvs.qiniuapi.com|d' /etc/hosts
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

      sync
      rm -f /etc/init.d/prepare.sh
      sync
      reboot
      exit
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

    mkdir -p $MOD/root/printer_data/misc
    mkdir -p $MOD/root/printer_data/tmp
    mkdir -p $MOD/root/printer_data/comms
    mkdir -p $MOD/root/printer_data/certs

    if  ! [ -d $MOD/opt/klipper/docs ]
     then
        mkdir -p $MOD/opt/klipper/docs
        cp /opt/klipper/docs/* $MOD/opt/klipper/docs
    fi

    if ! [ -d $MOD/opt/klipper/config ]
     then
        mkdir -p $MOD/opt/klipper/config
        cp /opt/klipper/config/* $MOD/opt/klipper/config
    fi

    chroot $MOD /opt/config/mod/.shell/root/start.sh &

    mkdir -p /data/lost+found
    sleep 10
    mount --bind /data/lost+found /data/.mod
}

start_prepare
