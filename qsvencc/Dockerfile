# docker build --force-rm=true -t qsvencc_build:1.0 .
# docker run --rm -it --mount type=bind,src=${PWD}/opt,dst=/opt --mount type=bind,src=${PWD}/entrypoint.sh,dst=/root/entrypoint.sh qsvencc_build:1.0

#FROM debian:latest
FROM build-base AS builder

RUN apt-get update && \
    \
    apt-get install -y --no-install-recommends \
        cmake \
        automake \
        libtool \
        meson \
        python3-dev \
        python3-distutils \
        \
#        libcunit1-dev \
    && \
    apt-get install -y --no-install-recommends \
        libavcodec-dev \
        libavutil-dev \
        libavformat-dev \
        libswresample-dev \
        libavfilter-dev \
        libass-dev \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

ENV SRC_DIR=/source
ENV BUILD_PREFIX=/opt

ENTRYPOINT sh -x /root/entrypoint.sh