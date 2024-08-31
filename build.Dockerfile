ARG IMAGE=ubuntu:20.04
ARG PREFIX=/usr/local

FROM ${IMAGE} AS builder

ARG DEBIAN_FRONTEND=noninteractive

ARG CC=gcc-10

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    $CC \
    gettext \
    git \
    ninja-build \
    unzip

COPY scripts/*.sh /usr/bin/

ARG TAG=nightly
ARG NEOVIM_VERSION

ARG PREFIX
ARG BUILD_TYPE=RelWithDebInfo
ARG MODE=install

RUN start.sh

FROM scratch

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/neovim/nvsi" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG PREFIX

COPY --from=builder ${PREFIX} ${PREFIX}
