#!/bin/bash

# "lanCode"
# "printerSerialNumber"
# Adventurer5M.json

# Check if the number of arguments is either 2 or 3.
if [ $# -ne 2 ] && [ $# -ne 3 ]; then 
    echo "Usage: $0 PRINT|CLOSE FILE [PRECLEAR]"; 
    exit 1; 
fi

# Define the path to cURL
CURL="/opt/cloud/curl-7.55.1-https/bin/curl"

# Extract current device's IP address based on wlan0 or eth0 interface.
ip=$(ip addr | grep inet | grep wlan0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
if [ "$ip" == "" ]; then 
    ip=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//'); 
fi

# Parse the serial number and LAN code from configuration file.
serialNumber=$(< "/opt/config/Adventurer5M.json" grep "printerSerialNumber"| cut  -d ":" -f2| awk '{print $1}' | sed 's|[",]||g')
checkCode=$(< "/opt/config/Adventurer5M.json" grep "lanCode"| cut  -d ":" -f2| awk '{print $1}' | sed 's|[",]||g')

# If the first argument is "CLOSE".
if [ "$1" == "CLOSE" ]; then
    $CURL -s \
        http://$ip:8898/control \
        -H 'Content-Type: application/json' \
        -d "{\"serialNumber\":\"$serialNumber\",\"checkCode\":\"$checkCode\",\"payload\":{\"cmd\":\"stateCtrl_cmd\",\"args\":{\"action\":\"setClearPlatform\"}}}" || \
        echo "No response from the printer with IP $ip. Please configure the printer. On the printer screen: 'Settings' -> 'WiFi Icon' -> 'Network Mode' -> enable the 'Local Networks Only' toggle."
else
    # If the first argument is "PRINT"
    if [ "$1" == "PRINT" ]; then
        # Initialize temporary printer file for EXCLUDE_OBJECT_DEFINE.
        echo "EXCLUDE_OBJECT_DEFINE RESET=1" >/tmp/printer 2>/dev/null
        head -1000 "/data/$2" | grep ^EXCLUDE_OBJECT_DEFINE >/tmp/printer 2>/dev/null

        # Parse M109 and M190 commands (nozzle and bed heating commands) from the provided file.
        M109=$(head -1000 "/data/$2" | grep "^M109" | head -1)
        [ "$M109" == "" ] && M109=$(head -1000 "/data/$2" | grep "^M104" | head -1 | sed 's|M104|M109|')
        M190=$(head -1000 "/data/$2" | grep "^M190" | head -1)
        [ "$M190" == "" ] && M190=$(head -1000 "/data/$2" | grep "^M140" | head -1 | sed 's|M140|M190|')

        # Check if both M190 (bed heating) and M109 (nozzle heating) commands are present.
        if [ "$M190" == "" ] || [ "$M109" == "" ]; then
            echo "RESPOND TYPE=error MSG=\"The file $2 does not contain bed heating commands (M140/M190) or nozzle heating commands (M104/M109).\"" >/tmp/printer
            exit 1
        fi

        # If the optional third argument is "PRECLEAR".
        if [ "$3" == "PRECLEAR" ]; then
            echo "$M190" >/tmp/printer
            echo "$M109" >/tmp/printer
            echo "_START_PRECLEAR" >/tmp/printer
            echo "RUN_SHELL_COMMAND CMD=zprint PARAMS=\"PRINT '$2'\"" >/tmp/printer
        else
            # Send the print command via cURL.
            $CURL -s \
                http://$ip:8898/printGcode \
                -H 'Content-Type: application/json' \
                -d "{\"serialNumber\":\"$serialNumber\",\"checkCode\":\"$checkCode\",\"fileName\":\"$2\",\"levelingBeforePrint\":true}'" || \
                echo "No response from the printer with IP $ip. Please configure the printer. On the printer screen: 'Settings' -> 'WiFi Icon' -> 'Network Mode' -> enable the 'Local Networks Only' toggle."
        fi
    else
        # If the command does not match "PRINT" or "CLOSE", provide usage instructions.
        echo "Usage: $0 PRINT|CLOSE FILE [PRECLEAR]"
        exit 1
    fi
fi
