#!/bin/zsh
# Install script for btop (advanced system monitoring tool)

if command -v btop >/dev/null 2>&1; then
  echo "btop is already installed."
else
  echo "Installing btop..."
  sudo dnf install -y btop
  if [ $? -eq 0 ]; then
    echo "btop installed successfully."
  else
    echo "Failed to install btop. Please check your package manager settings."
  fi
fi
