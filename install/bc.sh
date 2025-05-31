#!/bin/zsh
# Install script for bc (Basic Calculator)

if command -v bc >/dev/null 2>&1; then
  echo "bc is already installed."
else
  echo "Installing bc..."
  sudo dnf install -y bc
  if [ $? -eq 0 ]; then
    echo "bc installed successfully."
  else
    echo "Failed to install bc. Please check your package manager settings."
  fi
fi
