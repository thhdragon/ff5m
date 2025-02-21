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
    export MOD_VERSION_PATCH=$(cat /tmp/version_patch 2> /dev/null)

    export VERSION_STRING="$MOD_VERSION"
    if [ -n "$MOD_VERSION_PATCH" ]; then
        export VERSION_STRING=$(echo -e "${VERSION_STRING}\n${MOD_VERSION_PATCH}")
    fi
}

print_message() {
    local text="$1"
    
    "$BINS/typer" fill -p 0 380 -s 800 80
    "$BINS/typer" text -ha center -p 400 400 -c 00f0f0 -b 0 -f "Roboto 12pt" -t "$text"
}

print_progress() {
    local value="$1"
    
    value=$((value > 100 ? 100 : value))
    
    "$BINS/typer" fill -p 200 420 -s 400 40 -c 872187
    "$BINS/typer" fill -p 205 425 -s 390 30 -c 0
    
    local progress_width=$(( value * 380 / 100 ))
    "$BINS/typer" fill -p 210 430 -s $progress_width 20 -c 872187
    
    "$BINS/typer" fill -c 0 -p 610 400 -s 100 80
    "$BINS/typer" text -p 620 440 -va middle -c 00f0f0 -b 0 -t "${value}%"
}

print_prepare_status() {
    local text="$1"
    
    "$BINS/typer" fill -p 205 425 -s 390 30 -c 0
    "$BINS/typer" text -p 400 440 -ha center -va middle -c 00f0f0 -f "JetBrainsMono 8pt" -b 0 -t "${text}"
}

case "$1" in
    draw_loading)
        load_version
        xzcat /opt/config/mod/load.img.xz > /dev/fb0
        "$BINS/typer" text -ha center -p 236 360 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$VERSION_STRING"
        "$BINS/typer" text -ha center -p 592 360 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    
    draw_splash)
        load_version
        xzcat /opt/config/mod/splash.img.xz > /dev/fb0
        "$BINS/typer" text -ha center -p 236 300 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$VERSION_STRING"
        "$BINS/typer" text -ha center -p 592 300 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    
    boot_message)
        if [ -z "$2" ]; then
            echo "message text is missing"
            exit 1
        fi

        case "${@: -1}" in
            ERROR)
                color=c43c00
            ;;
            WARN)
                color=fa7c17
            ;;
            INFO)
                color=ffffff
            ;;
            *)
                color=b7a6b5
            ;;
        esac

        
        args=("$@")
        count=$((${#args[@]} - 2))
        
        messages=""
        for str in "${args[@]:1:($count - 1)}"; do
            messages="$messages"$'\n'"$str"
        done

        max_lines=3
        line_height=20
        bottom_offset=460

        height=$((count * line_height))
        y_offset=$((bottom_offset - height))
        
        "$BINS/typer" fill -p 0 $((bottom_offset - max_lines * line_height)) -s 800 $(((max_lines + 1) * line_height))

        if [ "$count" -gt 1 ]; then
            "$BINS/typer" text -ha center -p 400 $y_offset -c b7a6b5 -f "JetBrainsMono Bold 8pt" -t "$messages"
        fi

        uptime=$(awk '{print $1}' < /proc/uptime)
        "$BINS/typer" text -ha center -va middle -p 400 $bottom_offset -c $color -f "JetBrainsMono Bold 8pt" -t "$uptime >> ${args[*]:$count:1}"
    ;;
    
    print_file)
        if [ -z "$2" ]; then
            echo "File name is missing"
            exit 1
        fi
        
        print_message "$2"
        print_progress 0
    ;;
    
    print_progress)
        if [ -z "$2" ]; then
            echo "Progress value is missing"
            exit 1
        fi
        
        print_progress "$2"
    ;;
    
    print_status)
        if [ -z "$2" ]; then
            echo "Status is missing"
            exit 1
        fi
        
        print_prepare_status "$2"
    ;;
    
    end_print)
        message="$2"
        if [ -z "$message" ]; then
            message="Finished!"
        fi
        
        print_message "$message"
        print_progress "100"
    ;;
    
    backlight)
        value=$2
        if [ -z "$2" ]; then
            echo "Backlight value is missing"
            exit 1
        fi
        
        chroot "$MOD" /root/printer_data/py/backlight.py $value
    ;;
    *)
        echo "Usage: $0 <command> [args...]"
        exit 1
esac