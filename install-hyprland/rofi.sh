#!/bin/zsh
# Install script for rofi (text-based application launcher)

if command -v rofi >/dev/null 2>&1; then
  echo "rofi is already installed."
else
  echo "Installing rofi..."
  sudo dnf install -y rofi
  if [ $? -eq 0 ]; then
    echo "rofi installed successfully."
  else
    echo "Failed to install rofi. Please check your package manager settings."
  fi
fi
