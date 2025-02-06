#!/bin/bash

## Wi-fi connecting script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


INTERFACE="wlan0"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant.conf"


echo "Flushing IP address of eth0..."
ip addr flush dev eth0

echo "Killing processes..."
killall wpa_supplicant
killall udhcpc

rm -f "/var/run/wpa_supplicant/$INTERFACE"

echo "Restarting interface..."
ip link set "$INTERFACE" down
ip link set "$INTERFACE" up

echo "Restarting wpa_supplicant service..."
if ! wpa_supplicant -B -i "$INTERFACE" -c "$WPA_SUPPLICANT_CONF"; then
    echo "@@ Failed to restart wpa_supplicant." >&2
    exit 1
fi

echo "Initialize network..."

wpa_cli -i $INTERFACE enable_network all

echo "Checking connection status..."
for _ in $(seq 15); do
    STATUS=$(wpa_cli -i "$INTERFACE" status | grep wpa_state | awk -F= '{print $2}')
    
    if [[ "$STATUS" == "COMPLETED" ]]; then
        echo "Successfully connected!"
        echo "Requesting DHCP...."
        
        udhcpc -i $INTERFACE
        exit $?
    elif [[ "$STATUS" == "SCANNING" ]]; then
        echo "Connecting..."
    else
        echo "@@ Failed to connect. Current status: $STATUS"
        echo "Try to reconfigure..."
        wpa_cli -i "$INTERFACE" reconfigure
    fi
    
    sleep 1
done

exit 1
