#!/bin/zsh
# Install script for slurp (a tool for selecting a region of the screen)

if command -v slurp >/dev/null 2>&1; then
  echo "slurp is already installed."
else
  echo "Installing slurp..."
  sudo dnf install -y slurp
  if [ $? -eq 0 ]; then
    echo "slurp installed successfully."
  else
    echo "Failed to install slurp. Please check your package manager settings."
  fi
fi
