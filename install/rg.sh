#!/bin/zsh
# Install script for ripgrep (rg)

if command -v rg >/dev/null 2>&1; then
  echo "rg is already installed."
else
  echo "Installing rg (ripgrep)..."
  sudo dnf install -y ripgrep
fi
