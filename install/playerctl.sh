#!/bin/zsh
# Install script for playerctl (player control command-line utility)

if command -v playerctl >/dev/null 2>&1; then
  echo "playerctl is already installed."
else
  echo "Installing playerctl..."
  sudo dnf install -y playerctl
  if [ $? -eq 0 ]; then
    echo "playerctl installed successfully."
  else
    echo "Failed to install playerctl. Please check your package manager settings."
  fi
fi
