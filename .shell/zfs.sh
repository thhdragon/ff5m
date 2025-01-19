#!/bin/bash

## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

if [ $# -lt 2 ]; then echo "Usage: $0 {path} {size}"; exit 1; fi

NP=0
if [ "$3" = "NO_PROGRESS" ]; then
    NP=1
fi

# TODO: klipper sets strange variable which breaks python, idkw

env -i NO_PROGRESS=$NP nice -n 16 /usr/bin/python3 /root/printer_data/scripts/speed_test_rand.py "$1" $2
