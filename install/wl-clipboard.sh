#!/bin/zsh
# Install script for wl-clipboard (Wayland clipboard utilities)

if command -v wl-copy >/dev/null 2>&1; then
  echo "wl-clipboard is already installed."
else
  echo "Installing wl-clipboard..."
  sudo dnf install -y wl-clipboard
fi
