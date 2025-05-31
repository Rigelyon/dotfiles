#!/bin/zsh
# Install script for qt6-qtsvg (library for SVG support in Qt applications)

if rpm -q qt6-qtsvg >/dev/null 2>&1; then
  echo "qt6-qtsvg is already installed."
else
  echo "Installing qt6-qtsvg..."
  sudo dnf install -y qt6-qtsvg
  if [ $? -eq 0 ]; then
    echo "qt6-qtsvg installed successfully."
  else
    echo "Failed to install qt6-qtsvg. Please check your package manager settings."
  fi
fi
