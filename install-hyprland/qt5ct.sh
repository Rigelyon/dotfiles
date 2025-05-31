#!/bin/zsh
# Install script for qt5ct (Qt5 Configuration Tool)

if command -v qt5ct >/dev/null 2>&1; then
  echo "qt5ct is already installed."
else
  echo "Installing qt5ct..."
  sudo dnf install -y qt5ct
  if [ $? -eq 0 ]; then
    echo "qt5ct installed successfully."
  else
    echo "Failed to install qt5ct. Please check your package manager settings."
  fi
fi
