#!/bin/sh

if [ "$2" == "0" ];
    then
        echo "В фоне будет записано $1 MB"
        dd if=/dev/zero of=/data/test.img bs=1M count=$1 conv=fsync 2>/dev/null &
    else
        echo "Идет тестирование записи/чтения $1 MB данных. Ждите..."
        START=$(date +%s)
        dd if=/dev/zero of=/data/test.img bs=1M count=$1 conv=fsync 2>/dev/null
        END=$(date +%s)
        TIME=$(($END-$START))
        SPEED_W=$(($1/$TIME))

        START=$(date +%s)
        dd if=/data/test.img of=/dev/null bs=1M count=$1 conv=fsync 2>/dev/null
        END=$(date +%s)
        TIME=$(($END-START))
        SPEED_R=$(($1/$TIME))
        rm -f /data/test.img
        echo "Записано $1 MB. Запись ${SPEED_W} MB/s. Чтение ${SPEED_R} MB/s."
fi
