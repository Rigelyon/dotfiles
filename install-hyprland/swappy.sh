#!/bin/zsh
# Install script for swappy (image cropping tool)

if command -v swappy >/dev/null 2>&1; then
  echo "swappy is already installed."
else
  echo "Installing swappy..."
  sudo dnf install -y swappy
  if [ $? -eq 0 ]; then
    echo "swappy installed successfully."
  else
    echo "Failed to install swappy. Please check your package manager settings."
  fi
fi
