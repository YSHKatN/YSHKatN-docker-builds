#!/bin/bash

LIBVA_VER=2.21.0
GMMLIB_VER=22.3.19
MEDIA_DRIVER_VER=24.1.5

mkdir ${SRC_DIR}

# macros
echo "Build macros"
cd ${SRC_DIR}

git clone --depth 1 https://gitlab.freedesktop.org/xorg/util/macros.git
cd macros

./autogen.sh
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

mkdir build && cd build

meson setup \
    --prefix="$BUILD_PREFIX/qsv" \
    -Dzlib=enabled \
    ..

ninja -j$(nproc)
ninja install

cd .. && rm -r build


# libatomic_ops
echo Build libatomic_ops
cd ${SRC_DIR}

git clone --depth 1 https://github.com/ivmai/libatomic_ops.git
cd libatomic_ops/

./autogen.sh
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --enable-shared \
    --with-pic

make -j$(nproc)
make install

make distclean


# DRM (libdrm)
echo Build DRM
cd ${SRC_DIR}

git clone --depth 1 https://gitlab.freedesktop.org/mesa/drm.git libdrm

mkdir -p libdrm/build && cd libdrm/build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig" \
meson setup \
    --prefix="$BUILD_PREFIX/qsv" \
    -Ddefault_library=shared \
    -Dradeon=disabled \
    -Dudev=false \
    -Dcairo-tests=disabled \
    -Dvalgrind=disabled \
    -Dexynos=disabled \
    -Dfreedreno=disabled \
    -Domap=disabled \
    -Detnaviv=disabled \
    -Dintel=enabled \
    -Dnouveau=disabled \
    -Dradeon=disabled \
    -Damdgpu=disabled \
    -Dvmwgfx=disabled \
    -Dtegra=disabled \
    -Dvc4=disabled \
    -Dfreedreno-kgsl=false \
    -Dman-pages=disabled \
    -Dtests=false \
    -Dinstall-test-programs=false \
    ..

ninja -j$(nproc)
ninja install

cd .. && rm -r build

# Libva
echo Build Libva
cd ${SRC_DIR}

git clone --depth 1 -b ${LIBVA_VER} https://github.com/intel/libva.git
cd libva

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig" \
./autogen.sh

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig" \
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
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DOPENCL_ICD_LOADER_HEADERS_DIR="$BUILD_PREFIX/qsv/include" \
    -DBUILD_SHARED_LIBS=ON \
    -DOPENCL_ICD_LOADER_PIC=ON \
    -DOPENCL_ICD_LOADER_BUILD_TESTING=OFF \
    ..
#    -DCMAKE_BUILD_TYPE=Release \

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

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig" \
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


# Intel oneVPL GPU Runtime
echo Build Intel oneVPL GPU Runtime
cd ${SRC_DIR}

git clone --depth 1 https://github.com/oneapi-src/oneVPL-intel-gpu onevpl-gpu
cd onevpl-gpu

mkdir build && cd build

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig" \
cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
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

PKG_CONFIG_PATH="$BUILD_PREFIX/qsv/lib/pkgconfig" \
cmake \
    -DCMAKE_INSTALL_PREFIX="$BUILD_PREFIX/qsv" \
    -DBUILD_DISPATCHER=ON \
    -DBUILD_TOOLS=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DINSTALL_EXAMPLE_CODE=OFF \
    -DBUILD_PYTHON_BINDING=OFF \
    -DENABLE_VA=ON \
    -DENABLE_DRM=ON \
    ..
#    -DBUILD_DEV=OFF \

make -j$(nproc)
make install

cd .. && rm -r build


## QSVEncC
echo Build QSVEncC
cd ${SRC_DIR}

git clone --depth 1 https://github.com/rigaya/QSVEnc --recursive
cd QSVEnc
#git checkout 43c58d0c4a1c913c73d6b18b59bba93e2bdec2b9

PKG_CONFIG_PATH="$BUILD_PREFIX/avisynth/lib/pkgconfig:$BUILD_PREFIX/d2vwitch/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig:$BUILD_PREFIX/ffmpeg/n5.1/lib/pkgconfig" \
./configure \
    --prefix="$BUILD_PREFIX/qsv" \
    --opencl-headers="$BUILD_PREFIX/qsv/include"

# make時にOpenCLのincludedディレクトリを認識しない
ln -s $BUILD_PREFIX/qsv/include/CL /usr/include

PKG_CONFIG_PATH="$BUILD_PREFIX/avisynth/lib/pkgconfig:$BUILD_PREFIX/d2vwitch/lib/pkgconfig:$BUILD_PREFIX/qsv/lib/pkgconfig:$BUILD_PREFIX/qsv/lib64/pkgconfig:$BUILD_PREFIX/ffmpeg/n5.1/lib/pkgconfig" \
make -j$(nproc)
make install

# 実行にはlibvplのためにLD_LIBRARY_PATH="/opt/qsv/lib"が必要