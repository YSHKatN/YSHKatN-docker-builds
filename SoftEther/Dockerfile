FROM ubuntu:latest AS build

COPY Server.patch /

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        patch \
        pkg-config \
        cmake \
        make \
        g++ \
        libsodium-dev \
        libncurses-dev \
        libreadline-dev \
        libssl-dev \
        zlib1g-dev && \
    # create deb
    apt-get install -y --no-install-recommends \
        dpkg-dev \
        file

ENTRYPOINT sh -x /root/entrypoint.sh