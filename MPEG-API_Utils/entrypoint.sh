#!/bin/bash

#SRC_DIR=/source
#BUILD_PREFIX=/opt

mkdir ${SRC_DIR}

# MPEG-API_Utils
echo Build MPEG-API_Utils
cd ${SRC_DIR}

git clone --depth 1 https://github.com/YSHKatN/MPEG-API_Utils.git
cd MPEG-API_Utils

./compile.sh

mkdir -p ${BUILD_PREFIX}/MPEG-API_Utils/bin
cp bin/* ${BUILD_PREFIX}/MPEG-API_Utils/bin