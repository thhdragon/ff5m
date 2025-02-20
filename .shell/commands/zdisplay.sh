#!/bin/bash

## Display configuration script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

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
    local display_off=$(/opt/config/mod/.shell/commands/zconf.sh "$VAR_PATH" --get "display_off")
    return "$display_off"
}


apply_display_off() {
    killall "ffstartup-arm" > /dev/null 2>&1
    killall "firmwareExe" > /dev/null 2>&1

    "$SCRIPTS"/screen.sh backlight 0
    "$SCRIPTS"/screen.sh draw_splash
    "$SCRIPTS"/screen.sh backlight 100

    /etc/init.d/S00init reload
    "$SCRIPTS"/restart_klipper.sh --hard
    
    return 0
}

case "$1" in
    on)
        display_on
        sync

        if [ "$2" != "--skip-reboot" ]; then
            echo "Printer will be rebooted in 5 seconds..."
            echo "RESPOND prefix='//' MSG='Printer will be rebooted in 5 seconds...'" > /tmp/printer
            
            { sleep 5 && reboot; } &>/dev/null &
        fi

        exit 0
    ;;

    off)
        display_off
        apply_display_off
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
        echo "Usage: $0 on|off|test"; exit 1;
    ;;
esac

exit $?
