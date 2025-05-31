#!/bin/zsh
# Install script for inxi (system information tool)

if command -v inxi >/dev/null 2>&1; then
  echo "inxi is already installed."
else
  echo "Installing inxi..."
  sudo dnf install -y inxi
  if [ $? -eq 0 ]; then
    echo "inxi installed successfully."
  else
    echo "Failed to install inxi. Please check your package manager settings."
  fi
fi
