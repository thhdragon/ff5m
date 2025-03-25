#!/bin/bash

## Mod's Stock firmware initialization
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

source /opt/config/mod/.shell/common.sh

if ! mount | grep -q "$MOD/dev/pts"; then 
    mount --rbind /dev/pts "$MOD"/dev/pts
fi
