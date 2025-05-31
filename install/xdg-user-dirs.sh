#!/bin/zsh
# Install script for xdg-user-dirs (XDG User Directories)

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  echo "xdg-user-dirs is already installed."
else
  echo "Installing xdg-user-dirs..."
  sudo dnf install -y xdg-user-dirs
  if [ $? -eq 0 ]; then
    echo "xdg-user-dirs installed successfully."
  else
    echo "Failed to install xdg-user-dirs. Please check your package manager settings."
  fi
fi
