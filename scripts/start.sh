#!/bin/bash
# Copyright (c) 2024 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Test if PREFIX location is whithin limits
if [ ! "$PREFIX" == "/usr/local" ] && ! echo "$PREFIX" | grep -q ^"/opt"; then
  echo "ERROR:  PREFIX set to '$PREFIX'. Must either be '/usr/local' or within '/opt'."
  exit 1
fi

# If provided, set TAG to v$NEOVIM_VERSION
if [ -n "$NEOVIM_VERSION" ]; then
  TAG="v$NEOVIM_VERSION"
fi

# Download and extract source code
cd /tmp
git clone https://gitlab.b-data.ch/neovim/neovim.git
cd neovim
git switch --detach "$TAG"

# Build and install
dpkgArch="$(dpkg --print-architecture)"
if echo "$MODE" | grep -q ^"install"; then
  # Build
  make CMAKE_BUILD_TYPE="$BUILD_TYPE"
  # Strip binaries and libraries
  if [ "$MODE" == "install-strip" ]; then
    strip build/bin/nvim build/lib/*.so build/lib/nvim/parser/*.so
  fi
  # Override package name
  sed -i "s/nvim-linux64/nvim-linux-$dpkgArch/g" \
    build/CPackConfig.cmake
  # Create package
  cpack --config build/CPackConfig.cmake -G TGZ
  # Install
  tar zxf "build/nvim-linux-$dpkgArch.tar.gz" -C "$PREFIX" \
    --strip-components=1
fi
