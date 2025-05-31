#!/bin/zsh
# Install script for dunst (notification daemon)

if command -v dunst >/dev/null 2>&1; then
  echo "dunst is already installed."
else
  echo "Installing dunst..."
  sudo dnf install -y dunst
  if [ $? -eq 0 ]; then
    echo "dunst installed successfully."
  else
    echo "Failed to install dunst. Please check your package manager settings."
  fi
fi
