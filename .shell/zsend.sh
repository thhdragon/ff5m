#!/bin/sh

unset LD_PRELOAD
unset LD_LIBRARY_PATH
/usr/bin/python /root/printer_data/scripts/zsend.py $1
