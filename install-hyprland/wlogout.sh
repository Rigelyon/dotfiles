#!/bin/zsh
# Install script for wlogout (wayland logout utility)

if command -v wlogout >/dev/null 2>&1; then
  echo "wlogout is already installed."
else
  echo "Installing wlogout..."
  sudo dnf install -y wlogout
  if [ $? -eq 0 ]; then
    echo "wlogout installed successfully."
  else
    echo "Failed to install wlogout. Please check your package manager settings."
  fi
fi
