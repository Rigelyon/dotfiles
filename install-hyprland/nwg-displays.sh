#!/bin/zsh
# Install script for nwg-displays (a display management tool for Hyprland)

if command -v nwg-displays >/dev/null 2>&1; then
  echo "nwg-displays is already installed."
else
  echo "Installing nwg-displays..."
  sudo dnf install -y nwg-displays
  if [ $? -eq 0 ]; then
    echo "nwg-displays installed successfully."
  else
    echo "Failed to install nwg-displays. Please check your package manager settings."
  fi
fi
