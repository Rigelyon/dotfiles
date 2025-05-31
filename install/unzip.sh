#!/bin/zsh
# Install script for unzip

if command -v unzip >/dev/null 2>&1; then
  echo "unzip is already installed."
else
  echo "Installing unzip..."
  sudo dnf install -y unzip
  if [ $? -eq 0 ]; then
    echo "unzip installed successfully."
  else
    echo "Failed to install unzip. Please check your package manager settings."
  fi
fi
