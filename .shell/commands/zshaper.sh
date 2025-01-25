#!/bin/sh

## zshaper running script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

case $1 in
    --clear)
        rm -f /opt/config/mod_data/calibration_data*.csv
        
        images=$(find /opt/config/mod_data -name "calibration_data_*.png" -mtime +1 -maxdepth 1 -type f | sort)
        
        images_x=$(echo "$images" | grep -i "x.png" | head -n -1)
        images_y=$(echo "$images" | grep -i "y.png" | head -n -1)
        
        echo -e "${images_x}\n${images_y}" | xargs -r -I{} -- rm {}
    ;;
    --calculate)
        cp /tmp/*.csv /opt/config/mod_data/
        LD_PRELOAD= chroot $MOD /opt/config/mod/.root/zshaper.sh
    ;;
    *)
        echo "Unknow parameter value: '$1'"
        exit 1
    ;;
esac

exit $?
