#!/bin/sh

if [ "$2" == "0" ];
    then
        time dd if=/dev/urandom of=/data/test.img bs=1M count=$1 conv=fsync &
    else
        time dd if=/dev/urandom of=/data/test.img bs=1M count=$1 conv=fsync
        rm -f /data/test.img
fi
