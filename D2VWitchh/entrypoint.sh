#!/bin/bash

#SRC_DIR=/source
#BUILD_PREFIX=/opt

mkdir ${SRC_DIR}

# zimg
echo Build zimg
cd ${SRC_DIR}

git clone --depth 1 https://github.com/sekrit-twc/zimg.git --recursive
cd zimg

./autogen.sh
./configure \
    --prefix=$BUILD_PREFIX/d2vwitch \
    --disable-static \
    --enable-simd

make -j$(nproc)
make install

make distclean

# Vapoursynth
echo Build Vapoursynth
cd  ${SRC_DIR}

git clone --depth 1 https://github.com/vapoursynth/vapoursynth.git
cd vapoursynth

./autogen.sh
PKG_CONFIG_PATH="$BUILD_PREFIX/d2vwitch/lib/pkgconfig" \
./configure \
    --prefix=$BUILD_PREFIX/d2vwitch \
    --disable-static

make -j$(nproc)
make install

make distclean

# D2VWitch
echo Build D2VWitch
cd ${SRC_DIR}

git clone --depth 1 https://github.com/dubhater/D2VWitch.git
cd D2VWitch

sed -i s/"\['Core', 'GUI', 'Widgets'\]"/"'Widgets'"/ meson.build

mkdir build && cd build

PKG_CONFIG_PATH=$BUILD_PREFIX/d2vwitch/lib/pkgconfig:$BUILD_PREFIX/ffmpeg/n6.0/lib/pkgconfig \
meson setup \
    --prefix=$BUILD_PREFIX/d2vwitch \
    ..

ninja -j$(nproc)
ninja install

cd .. && rm -r build