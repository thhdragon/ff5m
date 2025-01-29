#!/bin/bash

## Auxiliary script for web interface changing
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

CFG_SCRIPT="/opt/config/mod/.shell/commands/zconf.sh"
CFG_PATH="/opt/config/mod_data/web.conf"

DEFAULT_WEB="fluidd"


load() {
    # Create default configuration if needed
    if [ ! -f "$CFG_PATH" ]; then
        cp "/opt/config/mod/.cfg/default/web.conf" "$CFG_PATH"
    fi
    
    WEB=$($CFG_SCRIPT $CFG_PATH --get "CLIENT" "$DEFAULT_WEB")
}

switch() {
    if [ "$WEB" = "$DEFAULT_WEB" ]; then
        WEB="mainsail"
    else
        WEB="$DEFAULT_WEB"
    fi
    
    $CFG_SCRIPT $CFG_PATH --set CLIENT="$WEB"
    
    sync
}

apply() {
    cat > $MOD/root/www/index.html <<EOF
<html>
<body>
    <script>window.location.href = './$WEB';</script>
    <p>If you are not redirected automatically, follow this <a href="./$WEB">link</a>.</p>
</body>
</html>
EOF
    
    sync
}

restart() {
    unset LD_PRELOAD
    chroot $MOD /opt/config/mod/.root/S70httpd restart
}


case "$1" in
    switch)
        load
        switch
        apply
        
        restart
    ;;
    apply)
        load
        apply
    ;;
    restart)
        restart
    ;;
    status)
        load
        echo "Current WebUI selected: $WEB"
    ;;
    *)
        echo "Usage: $0 (apply|switch|restart|status)"
        exit 1
    ;;
esac

exit $?