#!/bin/zsh
# Install script for python3-requests (Python HTTP library)

if python3 -c "import requests" >/dev/null 2>&1; then
  echo "python3-requests is already installed."
else
  echo "Installing python3-requests..."
  sudo dnf install -y python3-requests
  if [ $? -eq 0 ]; then
    echo "python3-requests installed successfully."
  else
    echo "Failed to install python3-requests. Please check your package manager settings."
  fi
fi
