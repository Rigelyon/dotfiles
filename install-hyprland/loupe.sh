#!/bin/zsh
# Install script for loupe (GTK image viewer)

if command -v loupe >/dev/null 2>&1; then
  echo "loupe is already installed."
else
  echo "Installing loupe..."
  sudo dnf install -y loupe
  if [ $? -eq 0 ]; then
    echo "loupe installed successfully."
  else
    echo "Failed to install loupe. Please check your package manager settings."
  fi
fi
