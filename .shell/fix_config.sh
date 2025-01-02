#!/bin/sh

set -x

fix_config()
{

    NEED_REBOOT=0
    PRINTER_BASE_ORIG="/opt/config/printer.base.cfg"
    PRINTER_CFG_PRIG="/opt/config/printer.cfg"
    PRINTER_BASE="/tmp/printer.base.cfg"
    PRINTER_CFG="/tmp/printer.cfg"

    cp ${PRINTER_BASE_ORIG} ${PRINTER_BASE}
    cp ${PRINTER_CFG_PRIG} ${PRINTER_CFG}

    # Rem стукач
    grep -q qvs.qiniuapi.com /etc/hosts || sed -i '2 i\127.0.0.1 qvs.qiniuapi.com' /etc/hosts

    grep -q 'include check_md5.cfg'   ${PRINTER_CFG} && sed -i '/include check_md5.cfg/d' ${PRINTER_CFG} && NEED_REBOOT=1

    sed -i 's|\[include ./mod/display_off.cfg\]|\[include ./mod/mod.cfg\]|' ${PRINTER_CFG}

    ! grep -q 'include ./mod/mod.cfg' ${PRINTER_CFG} && sed -i '2 i\[include ./mod/mod.cfg]' ${PRINTER_CFG} && NEED_REBOOT=1

    grep -q 'include mod.user.cfg' ${PRINTER_CFG} && sed -i 's|\[include mod.user.cfg\]|\[include ./mod_data/user.cfg\]|' ${PRINTER_CFG} && NEED_REBOOT=1

    ! grep -q 'include ./mod_data/user.cfg'  ${PRINTER_CFG} && sed -i '3 i\[include ./mod_data/user.cfg]' ${PRINTER_CFG} && NEED_REBOOT=1
    if ! grep -q '\[heater_bed' ${PRINTER_CFG}
        then
            NEED_REBOOT=1

            # Copy and remove from printer.base.cfg
            if grep -q '\[heater_bed' ${PRINTER_BASE}
                then
                    sed -e '/^\[heater_bed/,/^\[/d' ${PRINTER_BASE} >printer.base.tmp
                    diff -u ${PRINTER_BASE} printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
                    sed -i '$d' heater_bed.txt
                    num=$(wc -l heater_bed.txt|cut  -d " " -f1)
                    num=$(($num-1))
                    sed -e "/^\[heater_bed/,+${num}d;" ${PRINTER_BASE} >printer.base.tmp
                    cat printer.base.tmp >${PRINTER_BASE}
                    rm -f printer.base.tmp
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

            num=$(cat -n ${PRINTER_CFG} |grep ./mod_data/user.cfg| awk '{print $1}')
            head -n $num ${PRINTER_CFG} >printer.tmp
            echo "" >>printer.tmp
            cat heater_bed.txt >>printer.tmp
            num=$(($num+1))
            tail -n +$num ${PRINTER_CFG} >>printer.tmp
            cat printer.tmp >${PRINTER_CFG}
            rm heater_bed.txt || echo "Not heater_bed.txt"
    fi

    if grep -q '\[heater_bed' ${PRINTER_BASE}
        then
            NEED_REBOOT=1

            sed -e '/^\[heater_bed/,/^\[/d' ${PRINTER_BASE} >printer.base.tmp
            diff -u ${PRINTER_BASE} printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
            sed -i '$d' heater_bed.txt
            num=$(wc -l heater_bed.txt|cut  -d " " -f1)
            num=$(($num-1))
            sed -e "/^\[heater_bed/,+${num}d;" ${PRINTER_BASE} >printer.base.tmp
            cat printer.base.tmp >${PRINTER_BASE}
            rm -f heater_bed.txt printer.base.tmp
    fi

    # Удаляем fan_generic pcb_fan
    if grep -q '\[fan_generic pcb_fan' ${PRINTER_BASE}
        then
            NEED_REBOOT=1

            sed -e '/^\[fan_generic pcb_fan/,/^\[/d' ${PRINTER_BASE} >printer.base.tmp
            diff -u ${PRINTER_BASE} printer.base.tmp | grep -v "printer.base.cfg" |grep "^-" | cut -b 2- >heater_bed.txt
            sed -i '$d' heater_bed.txt
            num=$(wc -l heater_bed.txt|cut  -d " " -f1)
            num=$(($num-1))
            sed -e "/^\[fan_generic pcb_fan/,+${num}d;" ${PRINTER_BASE} >printer.base.tmp
            cat printer.base.tmp >${PRINTER_BASE}
            rm -f heater_bed.txt printer.base.tmp
    fi

    # Добавляем controller_fan driver_fan
    if ! grep -q '\[controller_fan driver_fan' ${PRINTER_BASE}
        then
            NEED_REBOOT=1
            echo '
[controller_fan driver_fan]
pin:PB7
fan_speed: 1.0
idle_timeout: 30
stepper: stepper_x, stepper_y, stepper_z
' >>${PRINTER_BASE}
    fi

    if [ ${NEED_REBOOT} -eq 1 ]
        then
            cat ${PRINTER_BASE} >${PRINTER_BASE_ORIG}
            sync
            cat ${PRINTER_CFG} >${PRINTER_CFG_ORIG}
            sync

            sleep 5
            sync

            reboot
            exit 1
    fi
}

mv /data/logFiles/fix_config.log.4 /data/logFiles/fix_config.log.5
mv /data/logFiles/fix_config.log.3 /data/logFiles/fix_config.log.4
mv /data/logFiles/fix_config.log.2 /data/logFiles/fix_config.log.3
mv /data/logFiles/fix_config.log.1 /data/logFiles/fix_config.log.2
mv /data/logFiles/fix_config.log /data/logFiles/fix_config.log.1
fix_config &>/data/logFiles/fix_config.log
