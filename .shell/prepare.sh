#!/bin/bash

## Mod's preparation script
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

MOD=/data/.mod/.zmod

set -x

start_prepare() {
    renice -16 $(ps | grep klippy.py | grep -v grep | awk '{print $1}')
    
    if [ ! -f /etc/init.d/S00init ]; then
        rm -f /etc/init.d/S00fix
        ln -s /opt/config/mod/.shell/S00init /etc/init.d/S00init
        /etc/init.d/S00init
    fi
    
    echo "System start" > /data/logFiles/ssh.log
    
    chroot $MOD /opt/config/mod/.root/start.sh &
}

mv /data/logFiles/prepare.log.4 /data/logFiles/prepare.log.5
mv /data/logFiles/prepare.log.3 /data/logFiles/prepare.log.4
mv /data/logFiles/prepare.log.2 /data/logFiles/prepare.log.3
mv /data/logFiles/prepare.log.1 /data/logFiles/prepare.log.2
mv /data/logFiles/prepare.log /data/logFiles/prepare.log.1

start_prepare &> /data/logFiles/prepare.log
