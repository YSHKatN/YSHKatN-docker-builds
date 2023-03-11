#!/bin/bash

#apt-get update
#apt-get upgrade -y
#apt-get clean
#rm -rf /var/lib/apt/lists/*

echo "make px4_drv"

BUILD_PATH="/source/px4_drv"
if [ -d "${BUILD_PATH}" ]; then
    rm -rf ${BUILD_PATH}
fi
mkdir -p ${BUILD_PATH}

cd ${BUILD_PATH}
#git clone -b develop https://github.com/nns779/px4_drv ${BUILD_PATH}
git clone --depth 1 https://github.com/otya128/px4_drv.git ${BUILD_PATH}
cd ./fwtool
make
#make ITEDTV_BUS_USE_WORKQUEUE=1
wget http://plex-net.co.jp/download/pxw3u4v1.3.zip
unzip -oj pxw3u4v1.3.zip x64/PXW3U4.sys
#wget http://plex-net.co.jp/download/pxw3u4v1.4.zip
#unzip -oj pxw3u4v1.4.zip pxw3u4v1/x64/PXW3U4.sys
./fwtool PXW3U4.sys it930x-firmware.bin
cd ../driver
make

cp ${BUILD_PATH}/fwtool/it930x-firmware.bin /out
cp ${BUILD_PATH}/driver/px4_drv.ko /out
cp ${BUILD_PATH}/etc/99-px4video.rules /out
