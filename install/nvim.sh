#!/bin/zsh
# Install script for nvim (Neovim)

if command -v nvim >/dev/null 2>&1; then
  echo "Neovim is already installed."
else
  echo "Installing Neovim..."
  sudo dnf install -y neovim
fi
