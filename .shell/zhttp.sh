#!/bin/bash

## Auxiliary script for web interface changing
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

CFG_SCRIPT="/opt/config/mod/.shell/zconf.sh"
CFG_PATH="/opt/config/mod_data/web.conf"

DEFAULT_WEB="fluidd"

# Create default configuration if needed
if [ ! -f "$CFG_PATH" ]; then
    cp "/opt/config/mod/.cfg/default/web.conf" "$CFG_PATH"
fi

# Update configuration

WEB=$($CFG_SCRIPT $CFG_PATH --get "CLIENT" "$DEFAULT_WEB")
if [ "$WEB" = "$DEFAULT_WEB" ]; then
    WEB="mainsail"
else
    WEB="$DEFAULT_WEB"
fi

$CFG_SCRIPT $CFG_PATH --set CLIENT="$WEB"

sync

unset LD_PRELOAD
chroot $MOD /opt/config/mod/.root/S70httpd restart
