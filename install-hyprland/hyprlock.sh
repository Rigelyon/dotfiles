#!/bin/zsh
# Install script for hyprlock

if command -v hyprlock >/dev/null 2>&1; then
  echo "hyprlock is already installed."
else
  echo "Installing hyprlock..."
  sudo dnf install -y hyprlock
  if [ $? -eq 0 ]; then
    echo "hyprlock installed successfully."
  else
    echo "Failed to install hyprlock. Please check your package manager settings."
  fi
fi
