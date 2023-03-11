#!/bin/bash

#AVISYNTH_VER=v3.7.2
LIBVA_VER=2.15.0
GMMLIB_VER=22.1.7
MEDIA_DRIVER_VER=22.4.4

mkdir ${SRC_DIR}

# macros
echo "Build macros"
cd ${SRC_DIR}

git clone --depth 1 https://gitlab.freedesktop.org/xorg/util/macros.git
cd macros

autoreconf -i
./configure

make -j$(nproc)
make install

make distclean

export ACLOCAL_PATH=/usr/local/share/aclocal

# zlib
echo Build zlib
cd ${SRC_DIR}

git clone --depth 1 https://github.com/madler/zlib.git
cd zlib

./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --64

make -j$(nproc)
make install

make distclean

# Generic PCI access library (libpciaccess)
echo Build Generic PCI access library
cd ${SRC_DIR}

git clone --depth 1 https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git
cd libpciaccess

autoreconf -fi

CFLAGS="-I$BUILD_PREFIX/include" \
LDFLAGS="-L$BUILD_PREFIX/lib" \
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --enable-shared \
    --disable-static \
    --with-pic \
    --with-zlib

make -j$(nproc)
make install

make distclean

# DRM (libdrm)
echo Build DRM
cd ${SRC_DIR}

git clone --depth 1 https://gitlab.freedesktop.org/mesa/drm.git libdrm

mkdir -p libdrm/build && cd libdrm/build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
meson \
#    --prefix="$BUILD_PREFIX/drm" \
    -Ddefault_library=shared \
    -Dlibkms=false \
    -Dudev=false \
    -Dcairo-tests=false \
    -Dvalgrind=false \
    -Dexynos=false \
    -Dfreedreno=false \
    -Domap=false \
    -Detnaviv=false \
    -Dintel=true \
    -Dnouveau=false \
    -Dradeon=false \
    -Damdgpu=false \
    -Dman-pages=false \
    -Dinstall-test-programs=false \
    ..

ninja -j$(nproc)
ninja install

#cd ..
#rm -r build

# Libva
echo Build Libva
cd ${SRC_DIR}

git clone --depth 1 -b ${LIBVA_VER} https://github.com/intel/libva.git
cd libva

autoreconf -i

PKG_CONFIG_PATH="$BUILD_PREFIX/drm/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig" \
./autogen.sh

PKG_CONFIG_PATH="$BUILD_PREFIX/drm/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig" \
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --disable-static \
    --enable-shared \
    --with-pic \
    --disable-docs \
    --enable-drm \
    --disable-glx \
    --disable-wayland

make -j$(nproc)
make install

#make distclean

# Intel Graphics Memory Management Library (gmmlib)
echo Build Intel Graphics Memory Management Library
cd ${SRC_DIR}

git clone --depth 1 -b intel-gmmlib-${GMMLIB_VER} https://github.com/intel/gmmlib

mkdir -p gmmlib/build && cd gmmlib/build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j$(nproc)
make install

cd .. && rm -r build

# Intel Media Driver for VAAPI
echo Build Intel Media Driver for VAAPI
cd ${SRC_DIR}

git clone --depth 1 -b intel-media-${MEDIA_DRIVER_VER} https://github.com/intel/media-driver

mkdir media-driver/build && cd media-driver/build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_KERNELS=ON \
    -DBYPASS_MEDIA_ULT=yes \
    ..

make -j$(nproc)
make install

cd .. && rm -r build


# DRM (libdrm) rebuild
echo Build DRM
cd ${SRC_DIR}/libdrm/build

ninja uninstall
cd .. && rm -r build

mkdir build && cd build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
meson \
    --prefix="$BUILD_PREFIX/qsv" \
    -Ddefault_library=shared \
    -Dlibkms=false \
    -Dudev=false \
    -Dcairo-tests=false \
    -Dvalgrind=false \
    -Dexynos=false \
    -Dfreedreno=false \
    -Domap=false \
    -Detnaviv=false \
    -Dintel=true \
    -Dnouveau=false \
    -Dradeon=false \
    -Damdgpu=false \
    -Dman-pages=false \
    -Dinstall-test-programs=false \
    ..

ninja -j$(nproc)
ninja install

cd .. && rm -r build


# Libva rebuild
echo Build Libva
cd ${SRC_DIR}/libva

make uninstall
make distclean

autoreconf -i

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
./autogen.sh

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --disable-static \
    --enable-shared \
    --with-pic \
    --disable-docs \
    --enable-drm \
    --disable-glx \
    --disable-wayland

make -j$(nproc)
make install

make distclean

# OpenCL
echo Build OpenCL
cd ${SRC_DIR}

mkdir opencl && cd opencl

git clone --depth 1 https://github.com/KhronosGroup/OpenCL-Headers.git headers
mkdir -p "$BUILD_PREFIX"/qsv/include/CL
cp -r headers/CL/* "$BUILD_PREFIX"/qsv/include/CL/.

git clone --depth 1 https://github.com/KhronosGroup/OpenCL-ICD-Loader.git loader
cd loader

mkdir build && cd build
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DOPENCL_ICD_LOADER_HEADERS_DIR="$BUILD_PREFIX/qsv/include" \
    -DBUILD_SHARED_LIBS=ON \
    -DOPENCL_ICD_LOADER_PIC=ON \
    -DOPENCL_ICD_LOADER_BUILD_TESTING=OFF \
    ..

make -j$(nproc)
make install

cat > OpenCL.pc << "EOF"
prefix=$BUILD_PREFIX/qsv
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: OpenCL
Description: OpenCL ICD Loader
Version: 9999
Libs: -L\${libdir} -lOpenCL
Cflags: -I\${includedir}
Libs.private: -ldl
EOF

cp OpenCL.pc "$BUILD_PREFIX"/qsv/lib/pkgconfig/OpenCL.pc

cd .. && rm -r build


# Intel Media SDK
echo Build Intel Media SDK
cd ${SRC_DIR}

git clone --depth 1 https://github.com/Intel-Media-SDK/MediaSDK msdk
mkdir msdk/build && cd msdk/build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_DISPATCHER=ON \
    -DBUILD_SAMPLES=OFF \
    -DBUILD_TUTORIALS=OFF \
    ..

make -j$(nproc)
make install

cd .. && rm -r build


# oneVPL
echo Build oneVPL
cd ${SRC_DIR}

git clone --depth 1 https://github.com/oneapi-src/oneVPL.git
cd oneVPL

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DBUILD_DISPATCHER=ON \
    -DBUILD_TOOLS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DINSTALL_EXAMPLE_CODE= OFF \
    -DBUILD_PYTHON_BINDING=OFF \
    ..
#    -DBUILD_DEV=OFF \

make -j$(nproc)
make install

cd .. && rm -r build

# AviSynthPlus
#echo Build AviSynthPlus
#cd ${SRC_DIR}
#
#apt-get update
#apt-get install -y --no-install-recommends libdevil-dev
#
#git clone --depth 1 -b ${AVISYNTH_VER} https://github.com/AviSynth/AviSynthPlus.git
#cd AviSynthPlus
#
#mkdir build && cd build
#
#cmake \
#    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX" \
#    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
#    ..
#
#make -j$(nproc)
#make install


## QSVEncC
echo Build QSVEncC
cd $SRC_DIR

git clone https://github.com/rigaya/QSVEnc --recursive
cd QSVEnc

PKG_CONFIG_PATH="$BUILD_PREFIX/avisynth/lib/pkgconfig:$BUILD_PREFIX/d2vwitch/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/ffmpeg/n4.4/lib/pkgconfig" \
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --opencl-headers="$BUILD_PREFIX/qsv/include"

# make時にOpenCLのincludedディレクトリを認識しない
ln -s $BUILD_PREFIX/qsv/include/CL /usr/include

make -j$(nproc)
make install

# 実行にはlibvplのためにLD_LIBRARY_PATH="/opt/qsv/lib"が必要