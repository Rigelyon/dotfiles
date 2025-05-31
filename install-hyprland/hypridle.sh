#!/bin/zsh
# Install script for hypridle

if command -v hypridle >/dev/null 2>&1; then
  echo "hypridle is already installed."
else
  echo "Installing hypridle..."
  sudo dnf install -y hypridle
  if [ $? -eq 0 ]; then
    echo "hypridle installed successfully."
  else
    echo "Failed to install hypridle. Please check your package manager settings."
  fi
fi
