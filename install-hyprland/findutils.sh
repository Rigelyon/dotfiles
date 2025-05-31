#!/bin/zsh
# Install script for findutils (GNU findutils)

if command -v find >/dev/null 2>&1; then
  echo "findutils is already installed."
else
  echo "Installing findutils..."
  sudo dnf install -y findutils
  if [ $? -eq 0 ]; then
    echo "findutils installed successfully."
  else
    echo "Failed to install findutils. Please check your package manager settings."
  fi
fi
