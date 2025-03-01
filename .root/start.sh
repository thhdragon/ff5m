#!/bin/sh

## Starting zmod services
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025, Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

echo "Starting services..."

/opt/config/mod/.root/S65moonraker start
/opt/config/mod/.root/S70httpd start
/opt/config/mod/.root/S45ntpd start

started=0
echo "Waiting moonraker to start..."
for _ in $(seq 0 30); do
    curl http://localhost:7125 > /dev/null 2>&1 && started=1 && break
    sleep 1
done

[ $started = 1 ] && echo "OK" || echo "FAIL"

echo "Services started"
