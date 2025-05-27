#!/bin/zsh
# Install script for fd (simple, fast and user-friendly alternative to find)

if command -v fd >/dev/null 2>&1; then
  echo "fd is already installed."
else
  echo "Installing fd..."
  sudo dnf install -y fd-find
fi
