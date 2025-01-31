#!/bin/bash

## Swap initialization script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


MOD=/data/.mod/.zmod
CFG_SCRIPT="/opt/config/mod/.shell/commands/zconf.sh"
CFG_PATH="/opt/config/mod_data/variables.cfg"


SWAP_SIZE="${1-"64M"}"

if [ -z "$SWAP_SIZE" ]; then
    echo "Usage: $0 <swap_size>"
    exit 1
fi


is_usb_disk() {
    local device=$1
    local device_name=$(basename "$device")
    
    if readlink -f "/sys/block/$device_name" | grep -q 'usb'; then
        return 0
    else
        return 1
    fi
}

size_convert() {
    size=$1
    case $size in
        *K) bytes=$((${size%K} * 1024)) ;;
        *M) bytes=$((${size%M} * 1024 * 1024)) ;;
        *G) bytes=$((${size%G} * 1024 * 1024 * 1024)) ;;
        *)  bytes=$size ;;  # Assume bytes if no suffix
    esac

    echo "$bytes"
}

make_swap() {
    swap_file=$1
    
    swapoff -a
    
    ret=0
    if [ -f "$swap_file" ]; then
        current_size=$(ls -l "$swap_file" | awk '{print $5}')
        desired_size=$(size_convert "$SWAP_SIZE")

        if [ ! "$current_size" -eq "$desired_size" ]; then
            echo "Recreating existing swap file..."
            rm -f "$swap_file"
            fallocate -l "$SWAP_SIZE" "$swap_file"
            ret=$?
        fi
    else
        echo "Generating swap file..."
        fallocate -l "$SWAP_SIZE" "$swap_file"
        ret=$?
    fi

    if [ $ret -ne 0 ]; then
        echo "Unable to create swap file"
        return 1
    fi

    chmod 600 "$swap_file"           \
        && mkswap "$swap_file"       \
        && swapon "$swap_file"       \
    
    return $?
}

activate_usb_swap() {
    echo "Creating SWAP on USB..."
    
    for device in /dev/sd*; do
        # Skip if it's a partition (e.g., /dev/sda1)
        if [[ $device =~ [0-9]$ ]]; then
            continue
        fi
        
        # Check if the device is a USB disk
        if is_usb_disk "$device"; then
            echo "Found USB disk: $device"
            
            partitions=$(fdisk -l "$device" | awk '/^ *[0-9]+/ {print $1 " " $4}' | sort -k2,2nr)
            if [ -z "$partitions" ]; then
                echo "No partitions found on $device. Please create a partition on the USB disk."
                continue
            fi
            
            echo "Disk has partitions: $(echo "$partitions" | wc -l)"
            
            while read -r partition size; do
                partition_path="${device}${partition}"
                mount_point=$(mount | grep "$partition_path" | awk '{print $3}')
                
                if [ -z "$mount_point" ]; then
                    echo "Partition $partition not mounted. Mounting..."
                    mount_point=$(mktemp -d)
                    
                    if ! mount -t vfat -o codepage=437,iocharset=utf8 "$partition_path" "$mount_point"; then
                        echo "Failed to mount $device; partition $partition"
                        rmdir "$mount_point"
                    fi
                fi
                
                echo "USB disk mounted at $mount_point; Size: $size"

                disk_size=$(size_convert "$size")
                desired_size=$(size_convert "$SWAP_SIZE")

                if [ "$disk_size" -lt "$desired_size" ]; then
                    echo "Partition not big enough!"
                    continue
                fi
                
                echo "Creating SWAP on USB..."
                make_swap "$mount_point/swap"
                
                if [ $? -eq 0 ]; then
                    echo "Swap file created and activated on $device"
                    return 0
                else
                    echo "Failed to enable swap file on $device"
                fi
            done <<< "$partitions"
        else
            echo "$device is not a USB disk."
        fi
        
        return 1
    done
}

activate_mmc_swap() {
    echo "Creating SWAP on eMMC..."
    
    make_swap "$MOD/root/swap"
    if [ $? -eq 0 ]; then
        echo "Swap file created and activated eMMC"
    else
        echo "Failed to enable swap file on eMMC"
    fi
}

cleanup_mounts() {
    mount | grep "/dev/sd" | awk '{print $1 " " $3}' | while read -r partition mount; do
        if ! ls "$partition" > /dev/null 2>&1; then
            echo "Unmounting dead mounting point: $mount"
            umount -l "$mount"
            
            if [[ $mount == /tmp/* ]]; then
                rmdir "$mount"
            fi
        fi
    done
}

swap=$($CFG_SCRIPT  $CFG_PATH --get "use_swap" "0")

case "$swap" in
    0)
        echo "Swap disabled."
        
        swapoff -a
        rm -f $MOD/root/swap
        
        exit 0
    ;;
    1)
        activate_mmc_swap
    ;;
    2)
        cleanup_mounts
        if ! activate_usb_swap; then
            echo "Failed to activate USB swap. Activating MMC swap instead."
            activate_mmc_swap
        fi
    ;;
    *)
        echo "Unsupported swap configuration: $swap"
        exit 1
    ;;
esac
