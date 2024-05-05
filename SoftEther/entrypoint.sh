#!/bin/bash

git clone --recursive --depth 1 https://github.com/SoftEtherVPN/SoftEtherVPN.git

patch -u SoftEtherVPN/src/Cedar/Server.c < /root/Server.patch

cd SoftEtherVPN

./configure
make -C build -j$(nproc)

cd build

cpack
cp softether-*.deb /out