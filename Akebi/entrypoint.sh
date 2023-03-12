#!/bin/bash

mkdir ${SRC_DIR}

# Akebi
echo "Build Akebi"
cd ${SRC_DIR}

git clone --depth 1 https://github.com/tsukumijima/Akebi
cd Akebi

go build -ldflags="-s -w" -a -o "akebi-https-server" "./https-server/"

mkdir -p /opt/bin
mv akebi-https-server /opt/bin/
