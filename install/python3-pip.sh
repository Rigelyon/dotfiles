#!/bin/zsh
# Install script for python3-pip (Python package installer)

if command -v pip3 >/dev/null 2>&1; then
  echo "python3-pip is already installed."
else
  echo "Installing python3-pip..."
  sudo dnf install -y python3-pip
  if [ $? -eq 0 ]; then
    echo "python3-pip installed successfully."
  else
    echo "Failed to install python3-pip. Please check your package manager settings."
  fi
fi
