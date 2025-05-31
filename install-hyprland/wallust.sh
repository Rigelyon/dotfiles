#!/bin/zsh
# Install script for wallust (wallpaper utility)

if command -v wallust >/dev/null 2>&1; then
  echo "wallust is already installed."
else
  echo "Installing wallust..."
  sudo dnf install -y wallust
  if [ $? -eq 0 ]; then
    echo "wallust installed successfully."
  else
    echo "Failed to install wallust. Please check your package manager settings."
  fi
fi
