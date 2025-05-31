#!/bin/zsh
# Install script for waybar (Wayland status bar)

if command -v waybar >/dev/null 2>&1; then
  echo "waybar is already installed."
else
  echo "Installing waybar..."
  sudo dnf install -y waybar
  if [ $? -eq 0 ]; then
    echo "waybar installed successfully."
  else
    echo "Failed to install waybar. Please check your package manager settings."
  fi
fi
