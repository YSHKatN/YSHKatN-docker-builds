# docker build --force-rm=true -t px4_drv_build:1.0 .
# docker run --rm --mount type=bind,src=$PWD/out,dst=/out px4_drv_build:1.0

FROM ubuntu:22.04 AS build_base

RUN apt-get update \
#    && apt-get upgrade -y \
    && apt-get install -y wget \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        make \
        g++ \
        linux-headers-$(uname -r) \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM build_base As build

COPY ./entrypoint.sh /root

ENTRYPOINT sh -x /root/entrypoint.sh