# docker build --force-rm=true -t d2vwitch_build:1.0 .
# docker run --rm -it --mount type=bind,src=${PWD}/opt,dst=/opt d2vwitch_build:1.0 /bin/bash
# ffmpegのpkgconfig必要

FROM build-base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # zimg, Vapoursynth
        autoconf \
        automake \
        libtool \
        \
        # Vapoursynth
        python3-dev \
        cython3 \
        \
        # D2VWitch
        meson \
        qtbase5-dev \
        qttools5-dev-tools && \
    \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

ENV SRC_DIR=/source
ENV BUILD_PREFIX=/opt

ENTRYPOINT /root/entrypoint.sh
