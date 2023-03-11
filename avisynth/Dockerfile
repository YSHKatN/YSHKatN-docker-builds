# docker build --force-rm=true -t avisynth_builder .
# docker run --rm -it --mount type=bind,src=${PWD}/opt,dst=/opt --mount type=bind,src=${HOME}/encode/ffmpeg/n4.4.2,dst=/opt/ffmpeg/n4.4 --mount type=bind,src=${HOME}/encode/ffmpeg/n5.0.1,dst=/opt/ffmpeg/n5.0 --mount type=bind,src=${PWD}/entrypoint.sh,dst=/root/entrypoint.sh avisynth_build:1.0

FROM build-base AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cmake \
        automake \
        libtool \
        meson \
        \
        autoconf \
        zlib1g-dev \
        \
        #tsdivider用
        libboost-program-options-dev \
        libboost-filesystem-dev

ENV SRC_DIR=/source
ENV BUILD_PREFIX=/opt

ENTRYPOINT sh -x /root/entrypoint.sh