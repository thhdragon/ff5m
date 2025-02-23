#!/bin/bash

## Mod's common variables and functions
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


MOD=/data/.mod/.zmod
SCRIPTS=/opt/config/mod/.shell
PY=/opt/config/mod/.py
CMDS=$SCRIPTS/commands
BINS=/opt/config/mod/.bin/exec
MOD_DATA=/opt/config/mod_data

NOT_FIRST_LAUNCH_F="/tmp/not_first_launch_f"
CUSTOM_BOOT_F="/tmp/custom_boot_f"

CFG_SCRIPT="$CMDS/zconf.sh"
VAR_PATH="$MOD_DATA/variables.cfg"

unset LD_PRELOAD

logged() {
    local default_log_level="     "

    local print=true
    local print_level=0
    local print_formatted=false
    local send_to_screen=false
    local screen_level=1
    local benchmark=false
    local log=true
    local log_file=""
    local log_level=0
    local log_format="%date% | %level% | %pid% | %script%:%line% | %message%"
    
    while [[ $# -gt 0 ]]; do
        local param="$1"; shift
        case "$param" in
            --no-print)
                print=false
            ;;
            --print-formatted)
                print_formatted=true
            ;;
            --print-level)
                print_level="$1"; shift
            ;;
            --no-log)
                log=false
            ;;
            --log-level)
                log_level="$1"; shift
            ;;
            --log-format)
                log_format="$1"; shift
            ;;
            --send-to-screen)
                send_to_screen=true
            ;;
            --screen-level)
                screen_level="$1"; shift;
            ;;
            --benchmark)
                benchmark=true
            ;;
            *)
                if [[ -z "$log_file" ]]; then
                    log_file="$param"
                else
                    echo "Unknown option: $param" >&2
                    return 1
                fi
            ;;
        esac
    done
    
    if $log && [ -z "$log_file" ]; then
        echo "Error: Log file not specified." >&2
        return 1
    fi
    
    if ! $log && ! $print && ! $send_to_screen; then
        echo "Error: Printing and logging disabled." >&2
        return 1
    fi
    
    
    messages_queue=()
    messages_queue_max=5
    
    add_to_queue() {
        local new_item="$1"
        if [ "${#messages_queue[@]}" -ge "$messages_queue_max" ]; then
            messages_queue=("${messages_queue[@]:1}")
        fi
        
        messages_queue+=("$new_item")
    }
    
    
    if $benchmark; then
        last_time=$(awk '{print $1}' < /proc/uptime)
    fi
    
    while IFS= read -r line; do
        local date_str="$(date '+%Y-%m-%d %H:%M:%S')"
        local pid=$$
        local script_name=$(basename "$0")
        local line_number=${BASH_LINENO[0]:-"n/a"}
        local func_name=${FUNCNAME[1]:-global}
        local line_log_level="$default_log_level"

        local line_bench=""
        if $benchmark; then
            local now=$(awk '{print $1}' < /proc/uptime)
            local diff=$(awk 'BEGIN{ print ('$now' - '$last_time') * 1000 }')
            local line_bench="$diff ms >> "
            last_time=$now
        fi
        
        local level=0
        if [[ $line = "@@"* ]]; then
            line_log_level="ERROR"; line="${line:2}"; level=3
        elif [[ $line = "??"* ]]; then
            line_log_level="WARN "; line="${line:2}"; level=2
        elif [[ $line = "//"* ]]; then
            line_log_level="INFO "; line="${line:2}"; level=1
        fi
        
        line="${line#"${line%%[![:space:]]*}"}"

        if $log || $print_formatted; then
            local log_entry="$log_format"
            log_entry="${log_entry//'%date%'/$date_str}"
            log_entry="${log_entry//'%level%'/$line_log_level}"
            log_entry="${log_entry//'%pid%'/$pid}"
            log_entry="${log_entry//'%func%'/$func_name}"
            log_entry="${log_entry//'%line%'/$line_number}"
            log_entry="${log_entry//'%script%'/$script_name}"
            log_entry="${log_entry//'%message%'/$line}"
        fi
        
        if $print && [ "$level" -ge "$print_level" ]; then
            if $print_formatted; then
                printf "%s\n" "$log_entry"
            else
                printf "%s\n" "${line_bench}${line}"
            fi
        fi
        
        if $send_to_screen && [ -n "$line" ] && [ "$level" -ge "$screen_level" ]; then
            add_to_queue "$level;;$line"
            $SCRIPTS/screen.sh boot_message "${messages_queue[@]}"
        fi
        
        if $log && [ "$level" -ge "$log_level" ]; then
            printf "%s\n" "${line_bench}${log_entry}" >> "$log_file"
        fi
    done
}
