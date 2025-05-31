#!/bin/zsh
# Install script for grim (screenshot utility)

if command -v grim >/dev/null 2>&1; then
  echo "grim is already installed."
else
  echo "Installing grim..."
  sudo dnf install -y grim
  if [ $? -eq 0 ]; then
    echo "grim installed successfully."
  else
    echo "Failed to install grim. Please check your package manager settings."
  fi
fi
