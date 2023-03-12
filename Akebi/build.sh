#!/bin/bash

APP_NAME=akebi
BUILDER=${APP_NAME}_builder
TARGET=${APP_NAME}

docker build --force-rm=true -t build-base ../common

docker build --force-rm=true -t ${BUILDER} .

docker image rm builder

docker run --rm \
    --mount type=bind,src=${PWD}/opt/,dst=/opt/ \
    --mount type=bind,src=${PWD}/entrypoint.sh,dst=/root/entrypoint.sh \
    ${BUILDER}