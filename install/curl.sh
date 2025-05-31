#!/bin/zsh
# Install script for curl

if command -v curl >/dev/null 2>&1; then
  echo "curl is already installed."
else
  echo "Installing curl..."
  sudo dnf install -y curl
  if [ $? -eq 0 ]; then
    echo "curl installed successfully."
  else
    echo "Failed to install curl. Please check your package manager settings."
  fi
fi
