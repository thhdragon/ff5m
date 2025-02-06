#!/bin/bash

## Mod's preparation script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license


MOD_CUSTOM_BOOT=0
source /opt/config/mod/.shell/common.sh

if [ ! -f /etc/init.d/S00init ]; then
    echo "@@ Missing initialization script. Initialize now."
    
    rm -f /etc/init.d/S00fix
    ln -s "$SCRIPTS/S00init" /etc/init.d/S00init
    /etc/init.d/S00init start
fi

if ! "$CMDS/zdisplay.sh" test; then
    # Init Wi-Fi
    
    echo "Initialize Wi-Fi..."
    if [ -f "/etc/wpa_supplicant.conf" ]; then
        echo "Configuration found"
        
        if ! ip link show | grep -q "wlan0"; then
            echo "Load kernel module."
            insmod /lib/modules/8821cu.ko
            modprobe 8821cu
        fi
        
        if ! ps | grep -q "[n]l80211"; then
            echo "Try to connect..."
            
            for _ in $(seq 5); do
                "$SCRIPTS/boot/wifi_connect.sh" 2>&1 | logged /data/logFiles/wifi.log --no-print
                ret="${PIPESTATUS[0]}"
                
                if [ "$ret" -eq 0 ]; then
                    MOD_CUSTOM_BOOT=1
                    echo "Connected"
                    break
                fi
                
                echo "@@ WPA start failed. Retry..."
                sleep 1
            done
        fi
        
        #TODO: Create AP if no active network configuration
    fi
fi


if [ "$MOD_CUSTOM_BOOT" -eq 1 ]; then    
    echo "Start wifi reconnect daemon."    
    killall "wpa_cli"
    wpa_cli -B -a "$SCRIPTS/boot/wifi_reconnect.sh" -i wlan0

    echo "Network initialized."
    touch "$CUSTOM_BOOT_F"
    
    sleep 1
    
    mkdir -p /dev/pts
    mount -t devpts devpts /dev/pts
    mount -t configfs none /sys/kernel/config -o rw,relatime
    mount -t debugfs none /sys/kernel/debug -o rw,relatime
    
    echo "Boot MCU."
    /opt/config/mod/.shell/boot/boot_mcu.sh
    
    echo "Start klipper."
    /opt/klipper/start.sh &> /dev/null
fi

echo "Boot sequence done"
