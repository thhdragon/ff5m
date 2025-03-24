#!/bin/bash

## Handling special boot flag
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

FLAGS=("SKIP_MOD" "SKIP_MOD_SOFT" "REMOVE_MOD" "REMOVE_MOD_SOFT" "klipper_mod_skip" "klipper_mod_remove")

check_special_boot_flag() {
    local path=$1

    # Check firmware image first
    if ls "$path"/Adventurer5M*.tgz &> /dev/null; then
        echo "FIRMWARE_IMAGE"
        return 0
    fi

    # Check init script
    if [ -f "$path/flashforge_init.sh" ]; then
        echo "FIRMWARE_SCRIPT"
        return 0
    fi

    # Check boot flags (supported FLAG or FLAG.ext)
    for file_name in "${FLAGS[@]}"; do
        if ! compgen -G "$path/$file_name*" > /dev/null; then
            continue
        fi

        for file in "$path/$file_name"*; do
            if [[ "$file" =~ ^$path/$file_name(\.[^/]*)?$ ]]; then
                echo "$file_name"
                return 0
            fi
        done
    done


    return 1
}

is_usb_disk() {
    local device=$1
    local device_name=$(basename "$device")
    
    if readlink -f "/sys/block/$device_name" | grep -q 'usb'; then
        return 0
    else
        return 1
    fi
}

search_special_boot_flag_usb() {
    local callback=$1
    echo "Searching for boot flag in USB files..."
    
    for device in /dev/sd*; do
        # Skip if it's a partition (e.g., /dev/sda1)
        if [[ $device =~ [0-9]$ ]]; then
            continue
        fi
        
        if is_usb_disk "$device"; then
            echo "// Found USB disk: $device"
            
            device_name=$(basename "$device")
            partitions=$(
                awk -v dev="$device_name" \
                    '$4 ~ dev"[0-9]+$" {print substr($4,length(dev)+1) " " $3/2048 "M"}'\
                    /proc/partitions \
                    | sort -k2,2n
            )
            
            if [ -z "$partitions" ]; then
                echo "No partitions found on $device."
                continue
            fi
            
            echo "Disk has partitions: $(echo "$partitions" | wc -l)"
            while read -r partition size; do
                partition_path="${device}${partition}"
                mount_point=$(mount | grep "$partition_path" | awk '{print $3}')
                was_mounted=true
                
                if [ -z "$mount_point" ]; then
                    echo "Partition $partition not mounted. Mounting temporarily..."
                    mount_point=$(mktemp -d)
                    was_mounted=false
                    
                    if ! mount -t vfat -o codepage=437,iocharset=utf8 "$partition_path" "$mount_point"; then
                        echo "Failed to mount $device; partition $partition"
                        rmdir "$mount_point"
                        continue
                    fi
                fi
                
                echo "USB disk mounted at $mount_point; Size: $size"

                found=$(check_special_boot_flag "$mount_point")

                if [ "$was_mounted" = false ]; then
                    umount "$mount_point"
                    rmdir "$mount_point"
                fi

                if [ -n "$found" ]; then
                    echo "// Boot flag found: $found"
                    eval "$callback" "$found"
                    return 0
                fi
            done <<< "$partitions"
        fi
    done

    return 1
}

search_special_boot_flag_root() {
    local callback=$1
    echo "Searching for boot flag in MMC files..."

    found=$(check_special_boot_flag "/opt/config/mod/")
    if [ -n "$found" ]; then
        echo "// Boot flag found: $found"
        eval "$callback" "$found"
        return 0
    fi
    
    return 1
}

search_for_klipper_mod() {
    local callback=$1
    echo "Searching for klipper mod files..."

    if [ -f "/etc/init.d/S00klipper_mod" ]; then
        echo "// Klipper mod found."
        eval "$callback" "KLIPPER_MOD"
        return 0
    fi
    
    return 1
}

handle_special_boot_flag() {
    local name="$1"
    
    case "$name" in
        SKIP_MOD)
            echo "?? Skipping mod load..."
            rm -f /opt/config/mod/SKIP_MOD
            touch /tmp/SKIP_MOD
            
            exit 0
            ;;
        SKIP_MOD_SOFT)
            echo "?? Skipping mod load in soft mode..."
            rm -f /opt/config/mod/SKIP_MOD_SOFT
            touch /tmp/SKIP_MOD_SOFT

            # oh-my-zsh
            if [ -d /root/.oh-my-zsh ]; then
                mount --bind /opt/config/mod/.zsh/.oh-my-zsh /root/.oh-my-zsh
            fi
            
            exit 0
            ;;
        REMOVE_MOD)
            echo "@@ Removing mod..."

            rm -f /opt/config/mod/REMOVE_MOD
            mount_data_partition
            
            cp -f /opt/config/mod/.shell/uninstall.sh /tmp/uninstall.sh
            /tmp/uninstall.sh
            
            exit 0
            ;;
        REMOVE_MOD_SOFT)
            echo "@@ Removing mod in soft mode..."
        
            rm -f /opt/config/mod/REMOVE_MOD_SOFT
            mount_data_partition

            cp -f /opt/config/mod/.shell/uninstall.sh /tmp/uninstall.sh
            /tmp/uninstall.sh --soft

            exit 0
            ;;
        klipper_mod_skip)
            echo "!! Klipper mod skipped. Continue boot"

            exit 1
        ;;
        FIRMWARE_IMAGE | FIRMWARE_SCRIPT)
            echo "!! Installation image found. Skipping the mod..."
            touch /tmp/SKIP_MOD

            exit 0
        ;;
        KLIPPER_MOD | klipper_mod_remove)
            echo "@@ Skipping mod because of Klipper Mod..."
            touch /tmp/SKIP_MOD

            exit 0
        ;;
        *)
            echo "@@ Unknown special boot flag \"$name\""
            exit 1
    esac
}

print_special_boot_flag() {
    local name="$1"

    echo "Flag: $name"
    exit 0
}

search() {
    local callback=$1

    search_special_boot_flag_usb "$callback" \
        || search_special_boot_flag_root "$callback" \
        || search_for_klipper_mod "$callback"

    ret=$?
    echo "// No special boot flag found."

    return $ret
}

case "$1" in
    test)
        search "print_special_boot_flag"
    ;;
    apply)
        search "handle_special_boot_flag"
    ;;
    *)
        echo "Usage $0 (test|apply)"
        exit 1
esac
