#!/bin/bash

## Wi-Fi state change handling script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

handle() {
    echo "Received Wi-Fi signal: " "$@"
    case "$2" in
        CONNECTED)
            echo "Connection Established";
        ;;
        DISCONNECTED)
            echo "?? Connection Lost";
            
            # TODO: Find a way to just reconnect
            "$SCRIPTS/boot/wifi_connect.sh"
        ;;
    esac
}

handle "$@" | logged "/data/logFiles/wifi.log"
