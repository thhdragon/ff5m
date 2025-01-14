#!/bin/sh

MOD=/data/.mod/.zmod

unset LD_PRELOAD

chroot $MOD /opt/config/mod/.shell/root/zshaper.sh
