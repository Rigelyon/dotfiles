#!/bin/zsh
# Install script for python3-pyquery (Python library for parsing HTML and XML)

if python3 -c "import pyquery" >/dev/null 2>&1; then
  echo "python3-pyquery is already installed."
else
  echo "Installing python3-pyquery..."
  sudo dnf install -y python3-pyquery
  if [ $? -eq 0 ]; then
    echo "python3-pyquery installed successfully."
  else
    echo "Failed to install python3-pyquery. Please check your package manager settings."
  fi
fi
