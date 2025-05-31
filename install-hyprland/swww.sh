#!/bin/zsh
# Install script for swww (a wallpaper setter for Hyprland)

if command -v swww >/dev/null 2>&1; then
  echo "swww is already installed."
else
  echo "Installing swww..."
  sudo dnf install -y swww
  if [ $? -eq 0 ]; then
    echo "swww installed successfully."
  else
    echo "Failed to install swww. Please check your package manager settings."
  fi
fi
