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
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout "$TAG"

# Build and install
if echo "$MODE" | grep -q ^"install"; then
  make CMAKE_BUILD_TYPE="$BUILD_TYPE"
  if [ "$MODE" == "install-strip" ]; then
    strip build/bin/nvim
  fi
  cpack --config build/CPackConfig.cmake -G TGZ
  tar zxf build/nvim-linux64.tar.gz -C "$PREFIX" --strip-components=1
fi
