#!/bin/bash

## Script to finish zmod to forge-x switching
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

rm -f /etc/init.d/S00fix
rm -f /etc/init.d/prepare.sh

ln -fs "/opt/config/mod/.shell/S00init" /etc/init.d/

sync
reboot
