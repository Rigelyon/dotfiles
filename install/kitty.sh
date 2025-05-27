#!/bin/zsh
# Install script for kitty terminal

if command -v kitty >/dev/null 2>&1; then
  echo "Kitty is already installed."
else
  echo "Installing Kitty..."
  sudo dnf install -y kitty
fi
