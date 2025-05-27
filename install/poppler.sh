#!/bin/zsh
# Install script for poppler (PDF rendering library and utilities)

if command -v pdftotext >/dev/null 2>&1; then
  echo "poppler is already installed."
else
  echo "Installing poppler..."
  sudo dnf install -y poppler
fi
