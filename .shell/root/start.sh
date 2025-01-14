#!/bin/sh

SWAP=$1
echo "SWAP=$SWAP"

if [ ! -f /root/swap ]; then
    dd if=/dev/zero of=/root/swap bs=1024 count=$((128 * 1024))
    mkswap /root/swap
fi

if [ "$SWAP" = "/root/swap" ]; then
    if ! grep -q "use_swap = 0" /opt/config/mod_data/variables.cfg; then
        swapon $SWAP
    fi
fi

synchronize_time() {
    for server in ru.pool.ntp.org 1.ru.pool.ntp.org 2.ru.pool.ntp.org 3.ru.pool.ntp.org \
    4.ru.pool.ntp.org ntp1.vniiftri.ru ntp2.vniiftri.ru ntp3.vniiftri.ru \
    ntp4.vniiftri.ru ntp5.vniiftri.ru ntp.sstf.nsk.ru timesstf.sstf.nsk.ru ntp.kam.vniiftri.net; do
        ntpd -dd -n -q -p $server && return
    done
}

if [ ! -f /tmp/started ]; then
    date 2025.01.01-00:00:00
    synchronize_time
fi

/opt/config/mod/.shell/root/S65moonraker start
/opt/config/mod/.shell/root/S70httpd start

if [ ! -f /tmp/started ]; then
    echo "Waiting to avoid race conditions (?) during Firmware startup..."
    sleep 15
else
    # Wait for Moonraker to start
    for _ in $(seq 0 15); do
        curl http://localhost:7125 > /dev/null 2>&1 && break
        sleep 1
    done
fi

cd /opt/config/mod/
git log | head -3 | grep Date > /opt/config/mod_data/date.txt
echo "ZSSH_RELOAD" > /tmp/printer

touch /tmp/started

if [ ! -f /tmp/started ]; then
    for _ in $(seq 0 50); do
        synchronize_time && break
        sleep 5
    done
    
    date
fi

echo "Start END"
