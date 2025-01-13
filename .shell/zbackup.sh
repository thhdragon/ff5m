#!/bin/sh
#
# Configuration backup and restore

PARAMS="-p /opt/config/backup.params.cfg"

if [ "$1" = "RESTORE" ] then 
    PARAMS="$PARAMS -m restore"
else  
    PARAMS="$PARAMS -m backup"; 
fi

if [ "$2" = 1 ]; then PARAMS="$PARAMS --dry"; fi
if [ "$3" = 1 ]; then PARAMS="$PARAMS --verbose"; fi

/opt/bin/python3 /root/printer_data/scripts/cfg_backup.py $PARAMS