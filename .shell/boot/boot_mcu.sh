#!/bin/bash

## MCU booting script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


TTY="/dev/ttyS1"
BAUD=115200
R_READY="Ready."
R_ACK="\x06"
R_OK="\x01"
CMD_BOOT="A"

READY_RETRIES=10
BOOT_RETRIES=10

print_hex() {
    echo -n "$1" | xxd -p -u | tr -d '\n'
    echo -n " | $1"
    echo
}

echo "Setting up serial port: $TTY"

if [ ! -e "$TTY" ]; then
    echo "@@ Serial: $TTY does not exist."
    exit 1
fi

echo "Configuring..."

stty -F "$TTY" $BAUD raw \
    && stty -F $TTY -brkint -icrnl -imaxbel -opost -onlcr -isig \
    && stty -F $TTY -icanon -iexten -echo -echoe -echok -echoctl -echoke

if [ "$?" -ne 0 ]; then
    echo "@@ Serial: Failed to configure $TTY"
    exit 1
fi

echo "// Waiting for MCU to become ready ..."

for _ in $(seq $READY_RETRIES); do
    buf=$(dd if="$TTY" bs=32 count=1 status=none)
    
    if [ -z "$buf" ]; then
        echo "@@ No data received from MCU."
        exit 1
    fi
    
    echo -n "MCU Recv: "
    print_hex "$buf"
    
    if [[ "$buf" == *"$R_READY"* ]]; then
        echo "// MCU Ready."
        break
    fi
done

echo "// Sending boot command..."

for _ in $(seq $BOOT_RETRIES); do
    echo -n "MCU Send: "
    print_hex "$CMD_BOOT"
    
    # Send the command
    echo -n -e "$CMD_BOOT" > "$TTY"
    buf=$(dd if="$TTY" bs=32 count=1 status=none)
    
    if [ -z "$buf" ]; then
        echo "@@ No response received from MCU."
        exit 2
    fi
    
    echo -n "MCU Recv: "
    print_hex "$buf"
    
    if [ "$buf" == "$R_ACK" ] || [ "$buf" == "$R_OK" ]; then
        echo "// MCU is starting."
        exit 0
    fi
done

echo "?? Didn't receive boot confirmation"
