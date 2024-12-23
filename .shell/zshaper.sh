#!/bin/sh

MOD=/data/.mod/.zmod

unset LD_PRELOAD

umount /data/.mod/
chroot $MOD /opt/config/mod/.shell/root/zshaper.sh
mount --bind /data/lost+found /data/.mod
