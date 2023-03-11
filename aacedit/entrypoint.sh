#!/bin/bash

#SRC_DIR=/source
#BUILD_PREFIX=/opt

mkdir ${SRC_DIR}

# aacedit
echo Build aacedit
cd ${SRC_DIR}

git clone --depth 1  https://bitbucket.org/amanelia/aacedit.git
cd aacedit

make -j$(nproc)

mkdir -p ${BUILD_PREFIX}/aacedit/bin
cp aacedit ${BUILD_PREFIX}/aacedit/bin/

make clean