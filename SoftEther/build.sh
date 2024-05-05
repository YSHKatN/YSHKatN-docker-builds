#!/bin/bash

docker build --force-rm=true -t softether5-build .

if [ -d ${PWD}/out ]; then
    mkdir "${PWD}/out"
fi

docker run --rm \
    --mount type=bind,src=${PWD}/Server.patch,dst=/root/Server.patch \
    --mount type=bind,src=${PWD}/entrypoint.sh,dst=/root/entrypoint.sh \
    --mount type=bind,src=${PWD}/out,dst=/out \
    softether5-build