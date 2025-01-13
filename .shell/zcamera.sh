#!/bin/sh
#
# Camera config
#

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

[ $6 = "RESTART" ] && /etc/init.d/S98camera restart
