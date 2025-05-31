#!/bin/zsh
# Install script for mpv (media player)

if command -v mpv >/dev/null 2>&1; then
  echo "mpv is already installed."
else
  echo "Installing mpv..."
  sudo dnf install -y mpv
  if [ $? -eq 0 ]; then
    echo "mpv installed successfully."
  else
    echo "Failed to install mpv. Please check your package manager settings."
  fi
fi
