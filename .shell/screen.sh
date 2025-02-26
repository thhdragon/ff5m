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
    
    "$BINS/typer" -db batch \
        --batch fill -p 0 370 -s 800 50 -c 0 \
        --batch text -ha center -p 400 400 -c 00f0f0 -f "Roboto 12pt" -t "$text"
}

print_progress() {
    local value="$1"
    
    value=$((value > 100 ? 100 : value))
    local progress_width=$(( value * 380 / 100 ))
    
    "$BINS/typer" -db batch \
        --batch fill    -c 0         -p 200 420 -s 400 40 \
        --batch stroke  -c 872187    -p 200 420 -s 400 40 -lw 4 -sd inner \
        --batch fill    -c 872187    -p 210 430 -s $progress_width 20 \
        --batch fill    -c 0         -p 610 420 -s 100 60  \
        --batch text    -c 00f0f0    -p 620 440 -va middle -b 0 -t "${value}%"
}

print_prepare_status() {
    local text="$1"
    
    "$BINS/typer" -db batch \
        --batch fill -p 205 425 -s 390 30 -c 0 \
        --batch text -p 400 440 -ha center -va middle -c 00f0f0 -f "JetBrainsMono 8pt" -b 0 -t "${text}"
}

print_time() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_left_panel ""
        return
    fi

    print_duration=$(convert_duration "$1")
    total_duration=$(convert_duration "$2")

    print_left_panel "$print_duration / $total_duration"
}

print_left_panel() {
    if [ -z "$1" ]; then
        "$BINS/typer" fill -c 0 -p 0 400 -s 200 80
        return
    fi

    "$BINS/typer" -db batch\
        --batch fill -c 0 -p 0 400 -s 200 80 \
        --batch text -p 180 440 -va middle -ha right -c 00f0f0 -b 0 -t "$1"
}

convert_duration() {
    local float_time=$1
    local rounded_time=$(printf "%.0f" "$float_time") # Round off the time to the nearest integer

    if (( rounded_time < 60 )); then
        echo "$rounded_time s"
    elif (( rounded_time < 3600 )); then
        local minutes=$((rounded_time / 60))
        echo "$minutes m"
    else
        local hours=$((rounded_time / 3600))
        echo "$hours h"
    fi
}

level_to_color() {
    local level="$1"
    local level_trimmed="${level%"${level##*[![:space:]]}"}"

    case "$level_trimmed" in
            3|ERROR)
                color=c43c00
            ;;
            2|WARN)
                color=fa7c17
            ;;
            1|INFO)
                color=ffffff
            ;;
            *)
                color=b7a6b5
            ;;
        esac

    echo "$color"
}

case "$1" in
    draw_loading)
        load_version

        if [ "$2" != "--no-clear" ]; then
            xzcat /opt/config/mod/load.img.xz > /dev/fb0
        fi
        
        "$BINS/typer" -db batch \
            --batch text -ha center -p 236 300 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$VERSION_STRING" \
            --batch text -ha center -p 592 300 -c 00f0f0 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    
    draw_splash)
        load_version
        if [ "$2" != "--no-clear" ]; then
            xzcat /opt/config/mod/splash.img.xz > /dev/fb0
        fi

        "$BINS/typer" -db batch \
            --batch text -ha center -p 236 300 -c 2b8787 -f "JetBrainsMono Bold 12pt" -t "v$VERSION_STRING" \
            --batch text -ha center -p 592 300 -c 2b8787 -f "JetBrainsMono Bold 12pt" -t "v$FIRMWARE_VERSION"
    ;;
    
    boot_message)
        shift
        if [ -z "$1" ]; then
            echo "message text is missing"
            exit 1
        fi
        
        args=("$@")
        count=${#args[@]}

        max_lines=5
        line_height=22
        bottom_offset=460

        batches=(
            --batch fill -c 0 -p 0 "$((bottom_offset - max_lines * line_height))" -s 800 "$(((max_lines + 1) * line_height))"
        )

        height=$(((count - 1) * line_height))
        y_offset=$((bottom_offset - height))

        for str in "${args[@]}"; do
            # Split argument into level and message
            level="${str%%;;*}"
            message="${str#*;;}"
            color=$(level_to_color "$level")

            batches+=(
                --batch text -ha left -va middle -p 10 "$y_offset" -c "$color" -f "JetBrainsMono Bold 8pt" -t "$message"
            )

            y_offset=$((y_offset + line_height))
        done

        uptime=$(awk '{print $1}' < /proc/uptime)
        batches+=(
            --batch text -ha right -va middle -p 790 "$bottom_offset" -c "00ffff" -f "JetBrainsMono Bold 8pt" -t "<< $uptime"
        )

        "$BINS/typer" -db batch "${batches[@]}"
    ;;
    
    print_file)
        if [ -z "$2" ]; then
            echo "File name is missing"
            exit 1
        fi
        
        print_message "$2"
        print_progress 0
        print_time ""
    ;;
    
    print_progress)
        if [ -z "$2" ]; then
            echo "Progress value is missing"
            exit 1
        fi
        
        print_progress "$2"
    ;;

    print_time)      
        print_time "$2" "$3"
    ;;

    print_temperature)
        print_left_panel "$2"
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
        print_time ""
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