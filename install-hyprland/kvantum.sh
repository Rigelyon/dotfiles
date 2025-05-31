#!/bin/zsh
# Install script for kvantum (theme engine for Qt applications)

if command -v kvantummanager >/dev/null 2>&1; then
  echo "kvantum is already installed."
else
  echo "Installing kvantum..."
  sudo dnf install -y kvantum
  if [ $? -eq 0 ]; then
    echo "kvantum installed successfully."
  else
    echo "Failed to install kvantum. Please check your package manager settings."
  fi
fi
