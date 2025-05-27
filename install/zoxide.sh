#!/bin/zsh
# Install script for zoxide (smarter cd command)

if command -v zoxide >/dev/null 2>&1; then
  echo "zoxide is already installed."
else
  echo "Installing zoxide..."
  sudo dnf install -y zoxide
fi
