#!/bin/sh

time dd if=/dev/urandom of=/data/test.img bs=1M count=100 conv=fsync
rm -f /data/test.img
