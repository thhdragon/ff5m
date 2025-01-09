#!/bin/sh

unset LD_PRELOAD
unset LD_LIBRARY_PATH

[ $# -eq 1 ] && /usr/bin/python /root/printer_data/scripts/zsend.py "$1"
[ $# -eq 2 ] && /usr/bin/python /root/printer_data/scripts/zsend.py "M23" "$2"
