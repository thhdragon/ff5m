#!/bin/sh

## Auxiliary script for zmod camera
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025 Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

if [ $1 = "RELOAD" ]; then /etc/init.d/S98camera reload; exit 0; fi

if [ $# -ne 6 ]; then echo "Используйте $0 START WIDTH HEIGHT FPS VIDEO RESTART"; exit 1; fi

echo "# Не редактируйте этот файл
# Используйте макрос
#
# CAMERA_ON WIDTH=$2 HEIGHT=$3 FPS=$4 VIDEO=$5
# или
# CAMERA_OFF WIDTH=$2 HEIGHT=$3 FPS=$4 VIDEO=$5
#
# Если камера включена, то отключите  камеру на экране принтера

# Запускать камеру (on|off)
START=$1

# Разрешение ширина: 1280
WIDTH=$2

# Разрешение высота: 720
HEIGHT=$3

# Кадров в секунду: 15
FPS=$4

# Видео устройство: video0
VIDEO=$5

# Настройки изображения камеры
E_SHARPNESS=255
E_BRIGHTNESS=0
E_CONTRAST=255
E_GAMMA=10
E_GAIN=1

" >/opt/config/mod_data/camera.conf

PID_FILE=/run/camera.pid

ss -tuln | grep 8080 > /dev/null; STREAM_ACIVE=$(( $? == 0 ))
[ -f "$PID_FILE" ] && kill -0 $(cat $PID_FILE) 2>/dev/null; ZCAM_ACTIVE=$(( $? == 0 ))

if (( $STREAM_ACIVE && !$ZCAM_ACTIVE )); then
cat > /tmp/printer << EOF
RESPOND TYPE=command MSG="action:prompt_begin Веб-Камера"
RESPOND TYPE=command MSG="action:prompt_text Камера уже включена! Выключите её  экране принтера и поворите попытку!"
RESPOND TYPE=command MSG="action:prompt_end"
RESPOND TYPE=command MSG="action:prompt_show"
EOF
    
    echo "Camera already running! Make sure it's disabled in printer's screen settings!"
    exit 1
fi

[ $6 = "RESTART" ] && /etc/init.d/S98camera restart
