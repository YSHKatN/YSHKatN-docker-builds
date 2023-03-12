#!/bin/bash

echo "Build tsreadex"
git clone --depth 1 https://github.com/xtne6f/tsreadex.git
cd tsreadex

make -j$(nproc)

cp tsreadex /opt/bin