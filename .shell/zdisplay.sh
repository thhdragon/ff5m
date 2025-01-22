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
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.shell/cfg/init.display_on.cfg
}

display_off() {
    chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py \
        --mode restore --avoid_writes \
        --config /opt/config/printer.cfg \
        --no_data \
        --params /opt/config/mod/.shell/cfg/init.display_off.cfg
}

test() {
    local is_display_on=$(< "$CFG_PATH" grep -q "display_off = 1"; echo $?)
    return "$is_display_on"
}


apply_display_off() {
    killall firmwareExe > /dev/null 2>&1 && xzcat /opt/config/mod/.shell/screen_off.raw.xz > /dev/fb0
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
            display_off
        else
            display_on
        fi
    ;;
    apply)
        if test; then
            echo "Turning display off"
            apply_display_off
        fi
    ;;
    test)
        test; ret=$?
        if [ "$ret" -eq 1 ]; then echo "Display enabled"; else echo "Display disabled"; fi
        exit $ret
    ;;
    *)
        echo "Usage: $0 on|off|init|test"; exit 1;
    ;;
esac

exit $?
