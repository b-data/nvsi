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

ARG IMAGE_LICENSE="MIT"
ARG IMAGE_SOURCE="https://gitlab.b-data.ch/neovim/nvsi"
ARG IMAGE_VENDOR="b-data GmbH"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ARG PREFIX

COPY --from=builder ${PREFIX} ${PREFIX}
