#!/bin/sh

##
## SSH tunnel for Telegram Bot
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

if [ $# -ne 8 ]; then echo "Используйте (START|STOP|RESTART|RELOAD) SSH_SERVER SSH_PORT SSH_USER VIDEO_PORT MOON_PORT REMOTE_RUN RESTART|NOTRESTART"; exit 1; fi

SSH_PUB=$( cat /opt/config/mod_data/ssh.pub.txt )

START='off'

if [ "$1" = "START" ]; then START='on'; fi;
if [ "$1" = "RESTART" ]; then /etc/init.d/S98zssh restart; exit; fi
if [ "$1" = "RELOAD" ];  then /etc/init.d/S98zssh reload;  exit; fi

CFG_SCRIPT="/opt/config/mod/.shell/commands/zconf.sh"
CFG_PATH="/opt/config/mod_data/ssh.conf"

# Create default configuration if needed
if [ ! -f "$CFG_PATH" ]; then
    cp "/opt/config/mod/.cfg/default/ssh.conf" "$CFG_PATH"
fi

# Update configuration
if [ ${START} = 'on' ]; then
    $CFG_SCRIPT $CFG_PATH --set START="on" \
                SSH_SERVER="$2" SSH_PORT="$3" \
                SSH_USER="$4"  VIDEO_PORT="$5" MOON_PORT="$6" REMOTE_RUN="\"$7\""

    echo "Поместите текст строчкой ниже в ~/.ssh/authorized_keys для пользователя $4 на ssh сервере $2"
    echo "${SSH_PUB}"
    echo "В файле authorized_keys уберите первые 2 символа '# ' - это коментарий"

else
    $CFG_SCRIPT $CFG_PATH --set START="off"
fi

[ "$8" = "RESTART" ] && /etc/init.d/S98zssh restart
