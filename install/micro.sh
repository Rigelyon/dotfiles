#!/bin/zsh
# Install script for micro editor

if command -v micro >/dev/null 2>&1; then
  echo "Micro is already installed."
else
  echo "Installing Micro..."
  sudo dnf install -y micro
fi
