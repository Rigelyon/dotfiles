#!/bin/zsh
# Install script for mpv-mpris (MPRIS support for mpv)

if rpm -q mpv-mpris >/dev/null 2>&1; then
  echo "mpv-mpris is already installed."
else
  echo "Installing mpv-mpris..."
  sudo dnf install -y mpv-mpris
  if [ $? -eq 0 ]; then
    echo "mpv-mpris installed successfully."
  else
    echo "Failed to install mpv-mpris. Please check your package manager settings."
  fi
fi
