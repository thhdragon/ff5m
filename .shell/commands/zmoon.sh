#!/bin/bash

## Sending Moonraker API request
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

CURL=$(find /opt/cloud/curl-*/bin/curl 2> /dev/null)

if [ -z "$CURL" ]; then
    echo "curl not found!"
    exit 1
fi

send() {
    local addr="http://localhost:7125/${1}"
    
    echo "Sending..."
    
    local http_code
    http_code=$($CURL -s -w "%{http_code}" -o /dev/null -X POST "$addr")
    if [ "$?" -ne 0 ]; then
        echo "Query failed \"$addr\". curl errored"
        exit 1
    fi
    
    if [ "$http_code" != "200" ]; then
        echo "Query failed \"$addr\". Moonraker respond: $http_code"
        exit 2
    fi
    
    echo "Done!"
    exit 0
}

CMD="$1"

if [ "$CMD" == "restart_klipper" ]; then
    send "printer/restart"
fi

if [ "$CMD" == "restart_firmware" ]; then
    send "printer/firmware_restart"
fi

if [ "$CMD" == "recover" ]; then
    send "machine/update/recover?name=forge-x&hard=true"
fi

echo "Unknown command \"$CMD\""
exit 1
