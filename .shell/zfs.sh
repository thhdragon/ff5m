#!/bin/sh

if [ $# -ne 2 ]; then echo "Usage: $0 {speed} {path}"; exit 1; fi

/opt/bin/python3 /root/printer_data/scripts/speed_test_rand.py $1 $2