#!/bin/sh

F="/opt/klipper/klippy/toolhead.py"

clear_klipper()
{
    find /opt/klipper/ -name __pycache__ -type d -exec rm -r "{}" \;
    sync
    find /opt/klipper/ -name *.pyc -exec rm "{}" \;
    sync
    echo "Klipper был изменен. Сейчас будет перезагрузка"
    sleep 5
#    reboot
}

if [ "$1" == "0" ]
    then
        grep -q "LOOKAHEAD_FLUSH_TIME = 0.5" $F && exit 0
        sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.250|' $F
        sync
    else
        grep -q "LOOKAHEAD_FLUSH_TIME = 0.250" $F && exit 0
        sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.5|' $F
        sync
fi

clear_klipper
