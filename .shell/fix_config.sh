#!/bin/sh

set -x

fix_config()
{

    NEED_REBOOT=0

    # Rem стукач
    grep -q qvs.qiniuapi.com /etc/hosts || sed -i '2 i\127.0.0.1 qvs.qiniuapi.com' /etc/hosts

    grep -q 'include check_md5.cfg'   /opt/config/printer.cfg && sed -i '/include check_md5.cfg/d'    /opt/config/printer.cfg && NEED_REBOOT=1

    sed -i 's|\[include ./mod/display_off.cfg\]|\[include ./mod/mod.cfg\]|' /opt/config/printer.cfg

    ! grep -q 'include ./mod/mod.cfg' /opt/config/printer.cfg && sed -i '2 i\[include ./mod/mod.cfg]' /opt/config/printer.cfg && NEED_REBOOT=1

    grep -q 'include mod.user.cfg' /opt/config/printer.cfg && sed -i 's|\[include mod.user.cfg\]|\[include ./mod_data/user.cfg\]|' /opt/config/printer.cfg && NEED_REBOOT=1

    ! grep -q 'include ./mod_data/user.cfg'  /opt/config/printer.cfg && sed -i '3 i\[include ./mod_data/user.cfg]'  /opt/config/printer.cfg && NEED_REBOOT=1
    if ! grep -q '\[heater_bed' /opt/config/printer.cfg
        then
            NEED_REBOOT=1
            cd /opt/config/

            # Copy and remove from printer.base.cfg
            if grep -q '\[heater_bed' /opt/config/printer.base.cfg
                then
                    sed -e '/^\[heater_bed/,/^\[/d' printer.base.cfg >printer.base.tmp
                    diff -u printer.base.cfg printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
                    sed -i '$d' heater_bed.txt
                    num=$(wc -l heater_bed.txt|cut  -d " " -f1)
                    num=$(($num-1))
                    sed -e "/^\[heater_bed/,+${num}d;" printer.base.cfg >printer.base.tmp
                    mv printer.base.tmp printer.base.cfg
                else
                    echo "[heater_bed]
heater_pin: PB9
sensor_type: Generic 3950
sensor_pin: PC3
pullup_resistor: 4700
control: pid
pid_Kp: 32.79
pid_Ki: 4.970
pid_Kd: 54.118
#control: watermark
#max_power: 1.0
min_temp: -100
max_temp: 130

" >heater_bed.txt
            fi

            num=$(cat -n printer.cfg |grep ./mod_data/user.cfg| awk '{print $1}')
            head -n $num printer.cfg >printer.tmp
            echo "" >>printer.tmp
            cat heater_bed.txt >>printer.tmp
            num=$(($num+1))
            tail -n +$num printer.cfg >>printer.tmp
            mv printer.tmp printer.cfg
            rm heater_bed.txt || echo "Not heater_bed.txt"
    fi

    if grep -q '\[heater_bed' /opt/config/printer.base.cfg
        then
            NEED_REBOOT=1
            cd /opt/config/
            sed -e '/^\[heater_bed/,/^\[/d' printer.base.cfg >printer.base.tmp
            diff -u printer.base.cfg printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
            sed -i '$d' heater_bed.txt
            num=$(wc -l heater_bed.txt|cut  -d " " -f1)
            num=$(($num-1))
            sed -e "/^\[heater_bed/,+${num}d;" printer.base.cfg >printer.base.tmp
            mv printer.base.tmp printer.base.cfg
            rm -f heater_bed.txt
    fi

    # Удаляем fan_generic pcb_fan
    if grep -q '\[fan_generic pcb_fan' /opt/config/printer.base.cfg
        then
            NEED_REBOOT=1
            cd /opt/config/
            sed -e '/^\[fan_generic pcb_fan/,/^\[/d' printer.base.cfg >printer.base.tmp
            diff -u printer.base.cfg printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
            sed -i '$d' heater_bed.txt
            num=$(wc -l heater_bed.txt|cut  -d " " -f1)
            num=$(($num-1))
            sed -e "/^\[fan_generic pcb_fan/,+${num}d;" printer.base.cfg >printer.base.tmp
            mv printer.base.tmp printer.base.cfg
            rm -f heater_bed.txt
    fi

    # Добавляем controller_fan driver_fan
    if ! grep -q '\[controller_fan driver_fan' /opt/config/printer.base.cfg
        then
            NEED_REBOOT=1
            echo '
[controller_fan driver_fan]
pin:PB7
fan_speed: 1.0
idle_timeout: 30
stepper: stepper_x, stepper_y, stepper_z
' >>/opt/config/printer.base.cfg
    fi

    sync

    if [ ${NEED_REBOOT} -eq 1 ]; then sync; reboot; exit 1; fi;
}

fix_config >>/data/logFiles/zmod.log 2>>/data/logFiles/zmod.log
