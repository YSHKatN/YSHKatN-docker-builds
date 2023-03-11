#!/bin/bash

KVER=`uname -r`

if [ `grep -e '^px4_drv' /proc/modules | wc -l` -ne 0 ]; then
    modprobe -r px4_drv;
fi

if [ ! -d "/lib/modules/${KVER}/misc" ]; then
    mkdir /lib/modules/${KVER}/misc
fi
chmod 755 /lib/modules/${KVER}/misc

rm -fv /etc/udev/rules.d/90-px4.rules

cp ./out/it930x-firmware.bin /lib/firmware/

install -D -v -m 644 ./out/px4_drv.ko /lib/modules/${KVER}/misc/px4_drv.ko
install -D -v -m 644 ./out/99-px4video.rules /etc/udev/rules.d/99-px4video.rules
depmod -a ${KVER}
modprobe px4_drv