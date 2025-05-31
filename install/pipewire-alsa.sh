#!/bin/zsh
# Install script for pipewire-alsa (PipeWire ALSA support)

if rpm -q pipewire-alsa >/dev/null 2>&1; then
  echo "pipewire-alsa is already installed."
else
  echo "Installing pipewire-alsa..."
  sudo dnf install -y pipewire-alsa
  if [ $? -eq 0 ]; then
    echo "pipewire-alsa installed successfully."
  else
    echo "Failed to install pipewire-alsa. Please check your package manager settings."
  fi
fi
