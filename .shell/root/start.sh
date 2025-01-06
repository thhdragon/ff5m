#!/bin/sh

SWAP="/root/swap"
if ! [ -f $SWAP ]; then dd if=/dev/zero of=$SWAP bs=1024 count=131072; mkswap $SWAP; fi;

if grep -q "use_swap = 2" /opt/config/mod_data/variables.cfg
    then
    FREE_SPACE=$(df /media 2>/dev/null| tail -1 | tr -s ' ' | cut -d' ' -f4)
    MIN_SPACE=$((128*1024))

    if [ "$FREE_SPACE" != "" ] && [ "$FREE_SPACE" -ge "$MIN_SPACE" ]
        then
            SWAP="/media/swap"
            if ! [ -f $SWAP ]; then dd if=/dev/zero of=$SWAP bs=1024 count=131072; mkswap $SWAP; fi;
    fi
    swapon $SWAP
fi

grep -q "use_swap = 0" /opt/config/mod_data/variables.cfg || swapon $SWAP

mount --bind /data/lost+found /data/.mod

date 2024.01.01-00:00:00

# Пробуем синхронизировать время
ntpd -dd -n -q -p ru.pool.ntp.org || \
ntpd -dd -n -q -p 1.ru.pool.ntp.org || \
ntpd -dd -n -q -p 2.ru.pool.ntp.org || \
ntpd -dd -n -q -p 3.ru.pool.ntp.org || \
ntpd -dd -n -q -p 4.ru.pool.ntp.org || \
ntpd -dd -n -q -p ntp1.vniiftri.ru || \
ntpd -dd -n -q -p ntp2.vniiftri.ru || \
ntpd -dd -n -q -p ntp3.vniiftri.ru || \
ntpd -dd -n -q -p ntp4.vniiftri.ru || \
ntpd -dd -n -q -p ntp5.vniiftri.ru || \
ntpd -dd -n -q -p ntp.sstf.nsk.ru || \
ntpd -dd -n -q -p timesstf.sstf.nsk.ru || \
ntpd -dd -n -q -p ntp.kam.vniiftri.net

/opt/config/mod/.shell/root/S65moonraker start
/opt/config/mod/.shell/root/S70httpd start

sleep 15
echo "ZSSH_RELOAD" >/tmp/printer

# 10 минут пробуем получить время
for i in `seq 0 50`
    do 
        ntpd -dd -n -q -p ru.pool.ntp.org && break
        ntpd -dd -n -q -p 1.ru.pool.ntp.org && break
        ntpd -dd -n -q -p 2.ru.pool.ntp.org && break
        ntpd -dd -n -q -p 3.ru.pool.ntp.org && break
        ntpd -dd -n -q -p 4.ru.pool.ntp.org && break
        ntpd -dd -n -q -p ntp1.vniiftri.ru && break
        ntpd -dd -n -q -p ntp2.vniiftri.ru && break
        ntpd -dd -n -q -p ntp3.vniiftri.ru && break
        ntpd -dd -n -q -p ntp4.vniiftri.ru && break
        ntpd -dd -n -q -p ntp5.vniiftri.ru && break
        ntpd -dd -n -q -p ntp.sstf.nsk.ru && break
        ntpd -dd -n -q -p timesstf.sstf.nsk.ru && break
        ntpd -dd -n -q -p ntp.kam.vniiftri.net && break
        sleep 5
done
date
echo "Start END"
