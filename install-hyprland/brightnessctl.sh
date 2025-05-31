#!/bin/zsh
# Install script for brightnessctl (a command-line utility for controlling backlight brightness)

if command -v brightnessctl >/dev/null 2>&1; then
  echo "brightnessctl is already installed."
else
  echo "Installing brightnessctl..."
  sudo dnf install -y brightnessctl
  if [ $? -eq 0 ]; then
    echo "brightnessctl installed successfully."
  else
    echo "Failed to install brightnessctl. Please check your package manager settings."
  fi
fi
