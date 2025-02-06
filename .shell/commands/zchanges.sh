#!/bin/bash

## Mod's parameters change handle
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


source /opt/config/mod/.shell/common.sh


key=$1
value=$2

if [ -z "$key" ]; then
    echo "Usage: $0 <key> <value>"
    exit 1
fi

message() {
    local text="$1"
    local prefix="${2-"info"}"
    
    echo "RESPOND PREFIX='$prefix' MSG='$text'" > /tmp/printer
}

command() {
    local value="$1"
    
    RESPOND "TYPE=command MSG='$value'" > /tmp/printer
}

case "$key" in
    display_off)
        if [ "$value" -eq 1 ]; then
            message "Не отключайте экран, если вы четко не понимаете как работает карта стола, z-offset и макросы START_PRINT и END_PRINT"
            message "https://github.com/ghzserg/zmod/wiki/FAQ"
            
            $SCRIPTS/commands/zdisplay.sh "off"
        else
            $SCRIPTS/commands/zdisplay.sh "on"
        fi
    ;;
    
    use_swap)
        $SCRIPTS/init_swap.sh
    ;;
    
    camera)
        if [ "$value" -eq 1 ]; then
            message "Изменить параметры камеры можно здесь: Конфигурация -> mod_data -> camera.conf"
            
            cam_pid_file="/run/camera.pid"
            ss -tuln | grep -q ":8080"; STREAM_ACTIVE=$(( $? == 0 ))
            [ -f "$cam_pid_file" ] && kill -0 "$(cat $cam_pid_file)" 2>/dev/null; STREAM_ACTIVE=$(( $? == 0 ))
            
            if (( STREAM_ACTIVE && !STREAM_ACTIVE )); then
                command "action:prompt_begin Веб-Камера"
                command "action:prompt_text Камера уже включена! Выключите её на экране принтера и повторите попытку!"
                command "action:prompt_end"
                command "action:prompt_show"
                
                exit 1
            fi
            
            /etc/init.d/S98camera start
        else
            /etc/init.d/S98camera stop
        fi
    ;;
    
    fix_e0017)
        if $SCRIPTS/commands/zfix_e0017.sh "$value"; then
            message "Klipper был изменен. Сейчас будет перезагрузка"
            sleep 5
            #reboot
        fi
    ;;
    
    zssh)
        if [ "$value" -eq 1 ]; then
            SSH_PUB=$( cat /opt/config/mod_data/ssh.pub.txt )
            
            message "Изменить параметры SSH можно здесь: Конфигурация -> mod_data -> ssh.conf"
            message "Поместите текст строчкой ниже в ~/.ssh/authorized_keys для указанного пользователя на ssh сервере"
            message "${SSH_PUB}"
            message "В файле authorized_keys уберите первые 2 символа '# ' - это комментарий"
            
            /etc/init.d/S98zssh zstart
        else
            /etc/init.d/S98zssh stop
        fi
    ;;
    tune_config)
        if [ "$value" -eq 1 ]; then
            chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
                --mode restore --avoid_writes --no_data                  \
                --config /opt/config/printer.cfg                         \
                --params /opt/config/mod/.cfg/tuning.cfg
        else
            chroot $MOD /bin/python3 /root/printer_data/py/cfg_backup.py \
                --mode restore --avoid_writes --no_data                  \
                --config /opt/config/printer.cfg                         \
                --params /opt/config/mod/.cfg/tuning.off.cfg
        fi
esac