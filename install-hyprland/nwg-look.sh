#!/bin/zsh
# Install script for nwg-look (a tool for managing Hyprland themes and looks)

if command -v nwg-look >/dev/null 2>&1; then
  echo "nwg-look is already installed."
else
  echo "Installing nwg-look..."
  sudo dnf install -y nwg-look
  if [ $? -eq 0 ]; then
    echo "nwg-look installed successfully."
  else
    echo "Failed to install nwg-look. Please check your package manager settings."
  fi
fi
