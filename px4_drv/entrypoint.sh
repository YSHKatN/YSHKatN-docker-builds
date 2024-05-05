#!/bin/bash

#PX4DRV_VER=1.3
PX4DRV_VER=1.4

echo "make px4_drv"

BUILD_PATH="/source/px4_drv"
if [ -d "${BUILD_PATH}" ]; then
    rm -rf ${BUILD_PATH}
fi
mkdir -p ${BUILD_PATH}

cd ${BUILD_PATH}
#git clone -b develop https://github.com/nns779/px4_drv ${BUILD_PATH}
#git clone --depth 1 https://github.com/otya128/px4_drv.git ${BUILD_PATH}
git clone --depth 1 https://github.com/tsukumijima/px4_drv.git ${BUILD_PATH}

cd ./fwtool

make
#make ITEDTV_BUS_USE_WORKQUEUE=1

wget http://plex-net.co.jp/download/pxq3u4v${PX4DRV_VER}.zip
# Ver 1.3
#unzip -oj pxq3u4v${PX4DRV_VER}.zip x64/PXQ3U4.sys
# Ver 1.4
unzip -oj pxq3u4v${PX4DRV_VER}.zip pxq3u4v1/x64/PXQ3U4.sys

#wget http://plex-net.co.jp/download/202104_PX-Q3U4_Driver.zip
#unzip -oj 202104_PX-Q3U4_Driver.zip 202104_PX-Q3U4_Driver/x64/PXQ3U4.sys

./fwtool PXQ3U4.sys it930x-firmware.bin

cd ../driver
make

cp ${BUILD_PATH}/fwtool/it930x-firmware.bin /out
cp ${BUILD_PATH}/driver/px4_drv.ko /out
cp ${BUILD_PATH}/etc/99-px4video.rules /out
