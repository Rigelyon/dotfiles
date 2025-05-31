#!/bin/zsh
# Install script for gawk (GNU Awk)

if command -v gawk >/dev/null 2>&1; then
  echo "gawk is already installed."
else
  echo "Installing gawk..."
  sudo dnf install -y gawk
  if [ $? -eq 0 ]; then
    echo "gawk installed successfully."
  else
    echo "Failed to install gawk. Please check your package manager settings."
  fi
fi
