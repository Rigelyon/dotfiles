#!/bin/zsh
# Install script for gvfs (GNOME Virtual File System)

if rpm -q gvfs >/dev/null 2>&1; then
  echo "gvfs is already installed."
else
  echo "Installing gvfs..."
  sudo dnf install -y gvfs
  if [ $? -eq 0 ]; then
    echo "gvfs installed successfully."
  else
    echo "Failed to install gvfs. Please check your package manager settings."
  fi
fi
