#!/bin/zsh
# Install script for git (version control system)

if command -v git >/dev/null 2>&1; then
  echo "git is already installed."
else
  echo "Installing git..."
  sudo dnf install -y git
  if [ $? -eq 0 ]; then
    echo "git installed successfully."
  else
    echo "Failed to install git. Please check your package manager settings."
  fi
fi
