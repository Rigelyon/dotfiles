#!/bin/zsh
# Install script for yad (GUI for shell scripts)

if command -v yad >/dev/null 2>&1; then
  echo "yad is already installed."
else
  echo "Installing yad..."
  sudo dnf install -y yad
  if [ $? -eq 0 ]; then
    echo "yad installed successfully."
  else
    echo "Failed to install yad. Please check your package manager settings."
  fi
fi
