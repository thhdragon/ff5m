#!/bin/sh

if [ "$2" == "0" ];
    then
        echo "В фоне будет записано $1 MB"
        dd if=/dev/urandom of=/data/test.img bs=1M count=$1 conv=fsync &
    else
        START=$(date +%s)
        dd if=/dev/urandom of=/data/test.img bs=1M count=$1 conv=fsync
        END=$(date +%s)
        TIME=$(($START-$END))
        SPEED_W=$(($1/$TIME))

        START=$(date +%s)
        dd if=/data/test.img of=/dev/zero bs=1M count=$1 conv=fsync
        END=$(date +%s)
        TIME=$(($START-$END))
        SPEED_R=$(($1/$TIME))
        rm -f /data/test.img
        echo "Записано $1 MB. Запись ${SPEED_W} MB/s. Чтение ${SPEED_R} MB/s."
fi
