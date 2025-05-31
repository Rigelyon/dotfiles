#!/bin/zsh
# Install script for mako (notification daemon)

if command -v mako >/dev/null 2>&1; then
  echo "mako is already installed."
else
  echo "Installing mako..."
  sudo dnf install -y mako
  if [ $? -eq 0 ]; then
    echo "mako installed successfully."
  else
    echo "Failed to install mako. Please check your package manager settings."
  fi
fi
