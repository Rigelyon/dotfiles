#!/bin/zsh
# Install script for pipewire-utils (utilities for PipeWire)

if rpm -q pipewire-utils >/dev/null 2>&1; then
  echo "pipewire-utils is already installed."
else
  echo "Installing pipewire-utils..."
  sudo dnf install -y pipewire-utils
  if [ $? -eq 0 ]; then
    echo "pipewire-utils installed successfully."
  else
    echo "Failed to install pipewire-utils. Please check your package manager settings."
  fi
fi
