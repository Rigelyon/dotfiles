#!/bin/zsh
# Install script for yazi (terminal file manager)

if command -v yazi >/dev/null 2>&1; then
  echo "Yazi is already installed."
else
  echo "Installing Yazi..."
  sudo dnf install -y yazi
fi
