#!/bin/bash

## Mod's version compatibility checking script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

test() {
    if [ -f "$MOD"/ZMOD ]; then
        echo "Found core version from ZMod!"
        return 1
    fi
    
    if [ ! -f "$FLASHED_VERSION_F" ]; then
        echo "Core version is missing!"
        return 1
    fi

    CORE_VERSION=$(cat "$FLASHED_VERSION_F")
    OTA_VERSION=$(cat "$VERSION_F")
    
    if [ "${CORE_VERSION%.*}" != "${OTA_VERSION%.*}" ]; then
        echo "Version doesn't match. Core: $CORE_VERSION; OTA: $OTA_VERSION"
        return 1
    fi

    echo "Version match. Core: $CORE_VERSION; OTA: $OTA_VERSION"
    return 0
}


case $1 in
    test)
        test
        exit $?
    ;;
    verify)
        if ! test; then
            message "The current version is not compatible with the flashed core firmware." "!!"
            message "Detected Core Version: $CORE_VERSION | Current Firmware Version: $OTA_VERSION" "!!"
            message "Please update your firmware by downloading the latest image from the Releases page." "!!"
            message "Visit: https://github.com/drA1ex/ff5m/releases" "!!"
        fi
    ;;
    *)
        echo "Usage: $0 (test|verify)"
        exit 1
    ;;
esac

exit 0
