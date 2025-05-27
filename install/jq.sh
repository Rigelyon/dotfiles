#!/bin/zsh
# Install script for jq (JSON processor)

if command -v jq >/dev/null 2>&1; then
  echo "jq is already installed."
else
  echo "Installing jq..."
  sudo dnf install -y jq
fi
