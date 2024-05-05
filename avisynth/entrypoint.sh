#!/bin/bash

#SRC_DIR=/source
#BUILD_PREFIX=/opt

AVISYNTH_VER=v3.7.3
LSMASHWORKS_VER=20210423


mkdir ${SRC_DIR}

# AviSynthPlus
echo Build AviSynthPlus
cd ${SRC_DIR}

git clone --depth 1 -b ${AVISYNTH_VER} https://github.com/AviSynth/AviSynthPlus.git
cd AviSynthPlus

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/avisynth" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    ..

make -j$(nproc)
make install

cd .. && rm -r build


# TIVTC
echo Build TIVTC
cd ${SRC_DIR}

git clone --depth 1 https://github.com/pinterf/TIVTC.git
cd TIVTC/src

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/avisynth" \
    ..

make -j$(nproc)
make install

cd .. && rm -r build


# MaskTools 2
echo Build MaskTools 2
cd ${SRC_DIR}

git clone --depth 1 https://github.com/pinterf/masktools.git
cd masktools

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/avisynth" \
    ..

make -j$(nproc)
make install

cd .. && rm -r build


# DeLogoHD
echo Build DeLogoHD
cd ${SRC_DIR}

git clone --depth 1 https://github.com/HomeOfAviSynthPlusEvolution/DelogoHD.git
cd DelogoHD

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/avisynth" \
    -DCMAKE_CXX_FLAGS=-msse4.1 \
    ..

make -j$(nproc)
mv libDelogoHD.so $BUILD_PREFIX/avisynth/lib/avisynth

cd .. && rm -r build


# MPEG2DecPlus
echo Build MPEG2DecPlus
cd ${SRC_DIR}

git clone --depth 1 https://github.com/Asd-g/MPEG2DecPlus.git
cd MPEG2DecPlus

sed -i 's/\/usr\/local\//\$\{BUILD_PREFIX\}\/avisynth\//' CMakeLists.txt

#mv /tmp/misc.h.patch .
#patch -p0 < misc.h.patch

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_LIBDIR=$BUILD_PREFIX/avisynth/lib \
    ..

# @ToDo yadifmod2のmakeを参考に変更
sed -i 's/\/avisynth\/include\/avisynth/\$\{BUILD_PREFIX\}\/avisynth\/include\/avisynth/' CMakeFiles/d2vsource.dir/flags.make

make -j$(nproc)
make install

cd .. && rm -r build


# FFMS2
echo Build FFMS2
cd ${SRC_DIR}

git clone --depth 1 https://github.com/FFMS/ffms2.git
cd ffms2

PKG_CONFIG_PATH="$BUILD_PREFIX/ffmpeg/n6.1/lib/pkgconfig" \
./autogen.sh

PKG_CONFIG_PATH="$BUILD_PREFIX/ffmpeg/n6.1/lib/pkgconfig" \
./configure \
    --prefix="$BUILD_PREFIX/avisynth" \
    --enable-avisynth \
    --disable-static

LD_LIBRARY_PATH="$BUILD_PREFIX/ffmpeg/n6.1/lib" \
make -j$(nproc) CPPFLAGS="-I$BUILD_PREFIX/avisynth/include/avisynth" LIBS="$LIBS -L$BUILD_PREFIX/ffmpeg/n6.1/lib/pkgconfig/../../lib"
make install

ln -s /opt/avisynth/lib/libffms2.so /opt/avisynth/lib/avisynth/libffms2.so


# l-smash
echo Build l-smash
cd ${SRC_DIR}

#git clone --depth 1 https://github.com/l-smash/l-smash.git
git clone --depth 1 https://github.com/Mr-Ojii/l-smash.git
cd l-smash

./configure \
    --prefix="$BUILD_PREFIX/avisynth" \
    --enable-shared \
    --disable-static

make -j$(nproc)
make install

make distclean

# L-SMASH-Works
echo Build L-SMASH-Works
cd ${SRC_DIR}

#git clone --depth 1 -b ${LSMASHWORKS_VER} https://github.com/HolyWu/L-SMASH-Works.git
git clone --depth 1 -b ${LSMASHWORKS_VER} https://github.com/Mr-Ojii/L-SMASH-Works.git
cd L-SMASH-Works/AviSynth

PKG_CONFIG_PATH="$BUILD_PREFIX/avisynth/lib/pkgconfig:$BUILD_PREFIX/ffmpeg/n4.4/lib/pkgconfig" \
LDFLAGS="-Wl,-Bsymbolic" \
meson setup \
    --prefix="$BUILD_PREFIX/avisynth" \
    build

cd build
ninja -j$(nproc) -v
ninja install

cd .. && rm -r build


# JoinLogoScpTrialSetLinux
echo Build JoinLogoScpTrialSetLinux
cd ${SRC_DIR}

git clone --recursive --depth 1 https://github.com/tobitti0/JoinLogoScpTrialSetLinux.git

# chpter_exe
cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules/chapter_exe/src/
sed -i -e "s/\/usr\/local/\$\(BUILD_PREFIX\)\/avisynth/" Makefile
make -j$(nproc)
cp chapter_exe ${BUILD_PREFIX}/avisynth/bin

# logoframe
cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules/logoframe/src
sed -i -e "s/\/usr\/local/\$\(BUILD_PREFIX\)\/avisynth/" Makefile
make -j$(nproc)
cp logoframe ${BUILD_PREFIX}/avisynth/bin

# join_logo_scp
cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules/join_logo_scp/src
make -j$(nproc)
cp join_logo_scp ${BUILD_PREFIX}/avisynth/bin

#cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial
#npm install
#npm link
#cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules
#mv join_logo_scp_trial ${BUILD_PREFIX}/jlst

# tsdivider
cd ${SRC_DIR}/JoinLogoScpTrialSetLinux/modules/tsdivider
mkdir build && cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j$(nproc)
cp tsdivider ${BUILD_PREFIX}/avisynth/bin


# delogo-AviSynthPlus-Linux
echo Build delogo-AviSynthPlus-Linux
cd ${SRC_DIR}

git clone --depth 1 https://github.com/tobitti0/delogo-AviSynthPlus-Linux.git
cd delogo-AviSynthPlus-Linux/src

sed -i -e "s/\/usr\/local/\$\(BUILD_PREFIX\)\/avisynth/" Makefile
sed -i -e "s/-std=gnu99/-std=c++11/" Makefile

make -j$(nproc) INSTALL_DIR="$BUILD_PREFIX/avisynth/lib/avisynth" CC="g++"
make install


# yadifmod2
echo yadifmod2
cd ${SRC_DIR}

git clone --depth 1 https://github.com/Asd-g/yadifmod2.git
cd yadifmod2

sed -i 's/\/usr\/local\//\$\{BUILD_PREFIX\}\/avisynth\//' CMakeLists.txt

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_LIBDIR=$BUILD_PREFIX/avisynth/lib \
    ..

make -j$(nproc) CXX_INCLUDES="-I$BUILD_PREFIX/avisynth/include/avisynth"
make install

cd .. && rm -r build