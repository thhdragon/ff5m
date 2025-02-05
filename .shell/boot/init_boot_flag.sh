#!/bin/bash

## Handling special boot flag
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


FLAGS=("SKIP_ZMOD" "SKIP_ZMOD_SOFT" "REMOVE_ZMOD" "SOFT_REMOVE_ZMOD")

check_special_boot_flag() {
    local path=$1

    for file_name in "${FLAGS[@]}"; do
        if [ -f "$path/$file_name" ]; then
            echo "$file_name"
            return 0
        fi
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
            echo "Found USB disk: $device"
            
            partitions=$(fdisk -l "$device" | awk '/^ *[0-9]+/ {print $1 " " $4}' | sort -k2,2nr)
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
                    echo "Boot flag found: $found"
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
        echo "Boot flag found: $found"
        eval "$callback" "$found"
        return 0
    fi
    
    return 1
}

handle_special_boot_flag() {
    local name="$1"
    
    case "$name" in
        SKIP_ZMOD)
            echo "Skipping mod load..."
            rm -f /opt/config/mod/SKIP_ZMOD
            touch /tmp/SKIP_ZMOD
            
            exit 0
            ;;
        SKIP_ZMOD_SOFT)
            echo "Skipping mod load in soft mode..."
            rm -f /opt/config/mod/SKIP_ZMOD_SOFT
            touch /tmp/SKIP_ZMOD_SOFT

            # oh-my-zsh
            if [ -d /root/.oh-my-zsh ]; then
                mount --bind /opt/config/mod/.zsh/.oh-my-zsh /root/.oh-my-zsh
            fi
            
            exit 0
            ;;
        REMOVE_ZMOD)
            echo "Removing mod..."
            mount_data_partition
            
            cp -f /opt/config/mod_data/.shell/uninstall.sh /tmp/uninstall.sh
            /tmp/uninstall.sh
            
            exit 0
            ;;
        SOFT_REMOVE_ZMOD)
            echo "Removing mod in soft mode..."
        
            mount_data_partition
            cp -f /opt/config/mod_data/.shell/uninstall.sh /opt/uninstall.sh
            /opt/uninstall.sh --soft

            exit 0
            ;;
        *)
            echo "Unknown special boot flag \"$name\""
            exit 1
    esac
}

search() {
    local callback=$1

    search_special_boot_flag_root "$callback"
    search_special_boot_flag_usb "$callback"
}

case "$1" in
    test)
        search "echo Flag:"
        echo "Done"
    ;;
    apply)
        search "handle_special_boot_flag"
    ;;
    *)
        echo "Usage $0 (test|apply)"
        exit 1
esac
