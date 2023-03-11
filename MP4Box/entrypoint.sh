#!/bin/bash

mkdir ${SRC_DIR}

# MP4Box
echo "Build MP4Box"
cd ${SRC_DIR}

git clone --depth 1 https://github.com/gpac/gpac.git
cd gpac

./configure \
    --static-bin \
    --prefix="$BUILD_PREFIX/mp4box"

make -j$(nproc)
make install

make distclean