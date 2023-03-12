FROM build-base AS builder

ARG GO_VER=1.18.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
    \
    wget -P /tmp https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz && \
    tar zxvf /tmp/go${GO_VER}.linux-amd64.tar.gz -C /usr/local/ && \
    rm /tmp/go${GO_VER}.linux-amd64.tar.gz && \
    \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=$PATH:/usr/local/go/bin

ENV SRC_DIR=/source
ENV BUILD_PREFIX=/opt

ENTRYPOINT sh -x /root/entrypoint.sh
