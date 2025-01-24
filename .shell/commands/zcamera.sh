#!/bin/bash

## Auxiliary script for zmod camera
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

CFG_SCRIPT="/opt/config/mod/.shell/commands/zconf.sh"
CFG_PATH="/opt/config/mod_data/camera.conf"

if [ "$1" = "RELOAD" ]; then /etc/init.d/S98camera reload; exit 0; fi

if [ $# -ne 6 ]; then echo "Используйте $0 START WIDTH HEIGHT FPS VIDEO RESTART"; exit 1; fi

# Create default configuration if needed
if [ ! -f "$CFG_PATH" ]; then
    cp "/opt/config/mod/.cfg/default/camera.conf" "$CFG_PATH"
fi

# Update configuration
$CFG_SCRIPT $CFG_PATH --set START="$1" WIDTH="$2" HEIGHT="$3" FPS="$4" VIDEO="$5"

PID_FILE=/run/camera.pid

ss -tuln | grep -q ":8080"; STREAM_ACIVE=$(( $? == 0 ))
[ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; ZCAM_ACTIVE=$(( $? == 0 ))

if (( STREAM_ACIVE && !ZCAM_ACTIVE )); then
cat > /tmp/printer << EOF
RESPOND TYPE=command MSG="action:prompt_begin Веб-Камера"
RESPOND TYPE=command MSG="action:prompt_text Камера уже включена! Выключите её экране принтера и поворите попытку!"
RESPOND TYPE=command MSG="action:prompt_end"
RESPOND TYPE=command MSG="action:prompt_show"
EOF
    
    echo "Camera already running! Make sure it's disabled in printer's screen settings!"
    exit 1
fi

[ "$6" = "RESTART" ] && /etc/init.d/S98camera restart
