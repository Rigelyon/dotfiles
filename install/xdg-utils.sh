#!/bin/zsh
# Install script for xdg-utils (XDG Utilities)

if command -v xdg-open >/dev/null 2>&1; then
  echo "xdg-utils is already installed."
else
  echo "Installing xdg-utils..."
  sudo dnf install -y xdg-utils
  if [ $? -eq 0 ]; then
    echo "xdg-utils installed successfully."
  else
    echo "Failed to install xdg-utils. Please check your package manager settings."
  fi
fi
