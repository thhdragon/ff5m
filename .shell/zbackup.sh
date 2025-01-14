#!/bin/sh
#
# Configuration backup and restore


MOD=/data/.mod/.zmod

CFG_PATH="/opt/config/mod_data/backup.params.cfg"

if [ ! -f $CFG_PATH ]; then
echo "[stepper_x] rotation_distance
[stepper_y] rotation_distance
[stepper_z] rotation_distance
" > $CFG_PATH
fi


PARAMS="-p ${CFG_PATH}"

if [ "$1" = "RESTORE" ]; then 
    PARAMS="-m restore ${PARAMS}"
else  
    PARAMS="-m backup ${PARAMS}"
fi

if [ "$2" = 1 ]; then PARAMS="$PARAMS --dry"; fi
if [ "$3" = 1 ]; then PARAMS="$PARAMS --verbose"; fi

# TODO: klipper sets LD_PRELOAD variable, idkw

LD_PRELOAD= chroot $MOD /bin/python3 /root/printer_data/scripts/cfg_backup.py $PARAMS
