#!/bin/zsh
# Install script for gvfs-mtp (Media Transfer Protocol support for GVFS)

if rpm -q gvfs-mtp >/dev/null 2>&1; then
  echo "gvfs-mtp is already installed."
else
  echo "Installing gvfs-mtp..."
  sudo dnf install -y gvfs-mtp
  if [ $? -eq 0 ]; then
    echo "gvfs-mtp installed successfully."
  else
    echo "Failed to install gvfs-mtp. Please check your package manager settings."
  fi
fi
