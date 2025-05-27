#!/bin/zsh
# Install script for ImageMagick (image manipulation tools)

if command -v convert >/dev/null 2>&1; then
  echo "ImageMagick is already installed."
else
  echo "Installing ImageMagick..."
  sudo dnf install -y ImageMagick
fi
