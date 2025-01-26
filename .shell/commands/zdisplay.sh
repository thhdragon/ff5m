#!/bin/bash

## Display configuration script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

CFG_PATH=/opt/config/mod_data/variables.cfg

display_on() {
    chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.cfg/init.display_on.cfg
}

display_off() {
    chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.cfg/init.display_off.cfg
}

test() {
    local display_off=$(/opt/config/mod/.shell/commands/zconf.sh "$CFG_PATH" --get "display_off")
    return "$display_off"
}


apply_display_off() {
    killall firmwareExe > /dev/null 2>&1
    xzcat /opt/config/mod/.shell/screen_off.raw.xz > /dev/fb0
    return 0
}

case "$1" in
    on)
        display_on
        reboot
    ;;
    off)
        display_off
        apply_display_off
    ;;
    init)
        if test; then
            display_on
        else
            display_off
        fi
    ;;
    apply)
        if ! test; then
            echo "Turning display off"
            apply_display_off
        fi
    ;;
    test)
        test; ret=$?
        if [ "$ret" -eq 0 ]; then echo "Display enabled"; else echo "Display disabled"; fi
        exit $ret
    ;;
    *)
        echo "Usage: $0 on|off|init|test"; exit 1;
    ;;
esac

exit $?
