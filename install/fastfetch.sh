#!/bin/zsh
# Install script for fastfetch (a fast and lightweight system information tool)

if command -v fastfetch >/dev/null 2>&1; then
  echo "fastfetch is already installed."
else
  echo "Installing fastfetch..."
  sudo dnf install -y fastfetch
  if [ $? -eq 0 ]; then
    echo "fastfetch installed successfully."
  else
    echo "Failed to install fastfetch. Please check your package manager settings."
  fi
fi
