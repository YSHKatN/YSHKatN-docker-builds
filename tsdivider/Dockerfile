FROM build-base

RUN apt-get update && \
    \
    apt-get install -y --no-install-recommends \
        cmake \
        libboost-program-options1.74-dev \
        libboost-filesystem1.74-dev \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*


#実行時
#libboost-filesystem1.74.0
#libboost-program-options1.74.0

