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
        rm -f /tmp/*.csv
        rm -f /opt/config/mod_data/*.csv
        rm -f /opt/config/mod_data/*.png
    ;;
    --calculate)
        cp /tmp/*.csv /opt/config/mod_data/
        LD_PRELOAD= chroot $MOD /opt/config/mod/.shell/root/zshaper.sh
    ;;
    *)
        echo "Unknow parameter value: '$1'"
        exit 1
    ;;
esac

exit $?
