#!/bin/zsh
# Install script for wget2 (Next Generation Wget)

if command -v wget2 >/dev/null 2>&1; then
  echo "wget2 is already installed."
else
  echo "Installing wget2..."
  sudo dnf install -y wget2
  if [ $? -eq 0 ]; then
    echo "wget2 installed successfully."
  else
    echo "Failed to install wget2. Please check your package manager settings."
  fi
fi
