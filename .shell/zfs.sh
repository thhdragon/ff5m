#!/bin/sh

if [ $# -lt 2 ]; then echo "Usage: $0 {path} {size}"; exit 1; fi

NP=0
if [ "$3" = "NO_PROGRESS" ]; then
    NP=1
fi

NO_PROGRESS=$NP nice -n 16 /usr/bin/python3 /root/printer_data/scripts/speed_test_rand.py "$1" $2
