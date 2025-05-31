#!/bin/zsh
# Install script for hyprland

if command -v Hyprland >/dev/null 2>&1; then
  echo "Hyprland is already installed."
else
  echo "Installing Hyprland..."
  sudo dnf install -y hyprland
  if [ $? -eq 0 ]; then
    echo "Hyprland installed successfully."
  else
    echo "Failed to install Hyprland. Please check your package manager settings."
  fi
fi
