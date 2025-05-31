#!/bin/zsh
# Install script for network-manager-applet (nm-applet)

if command -v nm-applet >/dev/null 2>&1; then
  echo "network-manager-applet is already installed."
else
  echo "Installing network-manager-applet..."
  sudo dnf install -y network-manager-applet
  if [ $? -eq 0 ]; then
    echo "network-manager-applet installed successfully."
  else
    echo "Failed to install network-manager-applet. Please check your package manager settings."
  fi
fi
