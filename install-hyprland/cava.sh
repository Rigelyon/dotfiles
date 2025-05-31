#!/bin/zsh
# Install script for cava (Audio Visualizer for Alsa)

if command -v cava >/dev/null 2>&1; then
  echo "cava is already installed."
else
  echo "Installing cava..."
  sudo dnf install -y cava
  if [ $? -eq 0 ]; then
    echo "cava installed successfully."
  else
    echo "Failed to install cava. Please check your package manager settings."
  fi
fi
