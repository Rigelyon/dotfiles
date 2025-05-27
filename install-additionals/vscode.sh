#!/bin/zsh
# Install script for Visual Studio Code

if command -v code >/dev/null 2>&1; then
  echo "Visual Studio Code is already installed."
else
  echo "Installing Visual Studio Code..."
  sudo dnf install -y code
fi