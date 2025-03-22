#!/bin/bash

## Script to finish zmod to forge-x switching
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

set -x

restore() {
    rm -f /etc/init.d/S00fix
    rm -f /etc/init.d/prepare.sh
    rm -f /etc/init.d/S99camera

    rm -f /opt/klipper/klippy/extras/zmod.py
    rm -f /opt/klipper/klippy/extras/zmod_color.py
    rm -f /root/printer_data/logs/zmod

    mv /opt/config/mod_data/camera.cfg /opt/config/mod_data/camera.cfg.old
    mv /opt/config/mod_data/ssh.cfg /opt/config/mod_data/ssh.cfg.old
    mv /opt/config/mod_data/web.cfg /opt/config/mod_data/web.cfg.old

    mv /opt/config/mod_data/variables.cfg /opt/config/mod_data/variables.cfg.old
    echo -e "[Variables]\n" > /opt/config/mod_data/variables.cfg

    ln -fs /opt/config/mod/.shell/S00init /etc/init.d/
    ln -fs /opt/config/mod/.shell/S55boot /etc/init.d/
    ln -fs /opt/config/mod/.shell/S60dropbear /etc/init.d/
    ln -fs /opt/config/mod/.shell/S98camera /etc/init.d/
    ln -fs /opt/config/mod/.shell/S98zssh /etc/init.d/
    ln -fs /opt/config/mod/.shell/S99root /etc/init.d/
    ln -fs /opt/config/mod/.shell/K99root /etc/init.d/

    ln -fns /opt/config/mod/.bin/runtime/14.2.0 /opt/lib/

    sync
    reboot
}

restore &> /data/logFiles/fix.log