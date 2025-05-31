#!/bin/zsh
# Install script for qt6ct (Qt6 Configuration Tool)

if command -v qt6ct >/dev/null 2>&1; then
  echo "qt6ct is already installed."
else
  echo "Installing qt6ct..."
  sudo dnf install -y qt6ct
  if [ $? -eq 0 ]; then
    echo "qt6ct installed successfully."
  else
    echo "Failed to install qt6ct. Please check your package manager settings."
  fi
fi
