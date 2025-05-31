#!/bin/zsh
# Install script for cliphist (Clipboard History Manager)

if command -v cliphist >/dev/null 2>&1; then
  echo "cliphist is already installed."
else
  echo "Installing cliphist..."
  sudo dnf install -y cliphist
  if [ $? -eq 0 ]; then
    echo "cliphist installed successfully."
  else
    echo "Failed to install cliphist. Please check your package manager settings."
  fi
fi
