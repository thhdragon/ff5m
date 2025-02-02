#!/bin/bash

MOD=/data/.mod/.zmod
SCRIPTS=/opt/config/mod/.shell
CMDS=$SCRIPTS/commands
MOD_DATA=/opt/config/mod_data

NOT_FIRST_LAUNCH_F="/tmp/not_first_launch_f"
CUSTOM_BOOT_F="/tmp/custom_boot_f"

CFG_SCRIPT="$CMDS/zconf.sh"
VAR_PATH="$MOD_DATA/variables.cfg"

unset LD_PRELOAD

add_date_prefix() {
    while IFS= read -r line; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') | $line"
    done
}

logged() {
    local log_file=$1
    local print=$2
    
    while IFS= read -r line; do
        log_entry="$(printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line")"
        
        # Avoid using `tee` by printing and writing to the file directly.
        if [ "$print" != "--no-print" ]; then
            printf "%s\n" "$log_entry"
        fi
        
        printf "%s\n" "$log_entry" >> "$log_file"
    done
}
