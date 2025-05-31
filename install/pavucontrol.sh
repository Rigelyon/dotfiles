#!/bin/zsh
# Install script for pavucontrol (PulseAudio Volume Control)

if command -v pavucontrol >/dev/null 2>&1; then
  echo "pavucontrol is already installed."
else
  echo "Installing pavucontrol..."
  sudo dnf install -y pavucontrol
  if [ $? -eq 0 ]; then
    echo "pavucontrol installed successfully."
  else
    echo "Failed to install pavucontrol. Please check your package manager settings."
  fi
fi
