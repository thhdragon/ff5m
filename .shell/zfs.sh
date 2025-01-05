#!/bin/sh

# Более точный замер времени - Alexander

SIZE=$1
FILE="/data/test.img"

FREE_SPACE=$(df /data | tail -1 | tr -s ' ' | cut -d' ' -f4)
MIN_SPACE=$(($SIZE*1024*1024))
if [ "$FREE_SPACE" -lt "$MIN_SPACE" ]
    then
        echo "Не хватает свободного места на запись $SIZE MB";
        exit 0
fi
if [ "$2" == "0" ]
    then
        echo "В фоне будет записано ${SIZE} MB"
        dd if=/dev/zero of=$FILE bs=1M count=${SIZE} conv=fsync 2>/dev/null &
    else
        echo "Идет тестирование записи/чтения ${SIZE} MB данных. Ждите..."

        read up rest </proc/uptime; t1="${up%.*}${up#*.}"
        dd if=/dev/zero of=$FILE bs=1M count=${SIZE} conv=fsync 2>/dev/null
        read up rest </proc/uptime; t2="${up%.*}${up#*.}"
        TIME_W=$(( 10*(t2-t1) ))

        read up rest </proc/uptime; t1="${up%.*}${up#*.}"
        dd if=$FILE of=/dev/null bs=1M count=${SIZE} conv=fsync 2>/dev/null
        read up rest </proc/uptime; t2="${up%.*}${up#*.}"
        TIME_R=$(( 10*(t2-t1) ))

        rm -f $FILE

        awk "BEGIN {print \"Записано $SIZE MB. Запись: \" ($SIZE * 1000 / $TIME_W) \" MB/s. Чтение: \" ($SIZE * 1000 / $TIME_R) \" MB/s.\"}"
fi
