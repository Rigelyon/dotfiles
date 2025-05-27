#!/bin/zsh
# Install script for resvg (SVG rendering library and CLI tool)

if command -v resvg >/dev/null 2>&1; then
  echo "resvg is already installed."
else
  echo "Installing resvg..."
  sudo dnf install -y resvg
fi
