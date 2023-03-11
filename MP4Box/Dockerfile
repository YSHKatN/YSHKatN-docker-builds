FROM build-base AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        zlib1g-dev \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

ENV SRC_DIR=/source
ENV BUILD_PREFIX=/opt

ENTRYPOINT /root/entrypoint.sh