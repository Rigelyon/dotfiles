#!/bin/zsh
# Install script for rofi-wayland (Wayland version of Rofi)

if command -v rofi-wayland >/dev/null 2>&1; then
  echo "rofi-wayland is already installed."
else
  echo "Installing rofi-wayland..."
  sudo dnf install -y rofi-wayland
  if [ $? -eq 0 ]; then
    echo "rofi-wayland installed successfully."
  else
    echo "Failed to install rofi-wayland. Please check your package manager settings."
  fi
fi
