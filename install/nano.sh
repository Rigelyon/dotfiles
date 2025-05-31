#!/bin/zsh
# Install script for nano (text editor)

if command -v nano >/dev/null 2>&1; then
  echo "nano is already installed."
else
  echo "Installing nano..."
  sudo dnf install -y nano
  if [ $? -eq 0 ]; then
    echo "nano installed successfully."
  else
    echo "Failed to install nano. Please check your package manager settings."
  fi
fi
