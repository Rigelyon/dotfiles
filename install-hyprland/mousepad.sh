#!/bin/zsh
# Install script for mousepad (text editor)

if command -v mousepad >/dev/null 2>&1; then
  echo "mousepad is already installed."
else
  echo "Installing mousepad..."
  sudo dnf install -y mousepad
  if [ $? -eq 0 ]; then
    echo "mousepad installed successfully."
  else
    echo "Failed to install mousepad. Please check your package manager settings."
  fi
fi
