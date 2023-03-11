FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        \
        make \
        g++ \
        pkg-config \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*


#ENV SRC_DIR=/source
#ENV BUILD_PREFIX=/opt