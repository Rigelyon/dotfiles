#!/bin/zsh
# Install script for fzf (fuzzy finder)

if command -v fzf >/dev/null 2>&1; then
  echo "fzf is already installed."
else
  echo "Installing fzf..."
  sudo dnf install -y fzf
fi
