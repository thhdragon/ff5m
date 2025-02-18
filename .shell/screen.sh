#!/bin/bash

## Screen drawing script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

load_version() {
    export FIRMWARE_VERSION=$(cat /root/version)
    export MOD_VERSION=$(cat /opt/config/mod/version.txt)
}

case "$1" in
    draw_loading)
        load_version
        xzcat /opt/config/mod/load.img.xz > /dev/fb0
        "$BINS/typer" text -ha center -p 235 380 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$MOD_VERSION"
        "$BINS/typer" text -ha center -p 584 380 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    draw_splash)
        load_version
        xzcat /opt/config/mod/splash.img.xz > /dev/fb0
        "$BINS/typer" text -ha center -p 235 380 -c 035050 -f "JetBrainsMono Bold 12pt" -t "v$MOD_VERSION"
        "$BINS/typer" text -ha center -p 584 380 -c 035050 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    
    boot_message)
        if [ -z "$2" ]; then
            echo "message Text missing"
            exit 1
        fi
        
        uptime=$(awk '{print $1}' < /proc/uptime)
        
        "$BINS/typer" fill -p 0 440 -s 800 40
        "$BINS/typer" text -ha center -p 400 460 -c ffffff -b 0 -f "JetBrainsMono Bold 8pt" -t "$uptime >>  $2"
    ;;
    *)
        echo "Usage: $0 {draw_loading|draw_splash}"
        exit 1
esac