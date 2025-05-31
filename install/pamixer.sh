#!/bin/zsh
# Install script for pamixer (volume control utility)

if command -v pamixer >/dev/null 2>&1; then
  echo "pamixer is already installed."
else
  echo "Installing pamixer..."
  sudo dnf install -y pamixer
  if [ $? -eq 0 ]; then
    echo "pamixer installed successfully."
  else
    echo "Failed to install pamixer. Please check your package manager settings."
  fi
fi
