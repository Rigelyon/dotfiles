#!/bin/zsh
# Install script for AppImageLauncher (AppImage integration tool)

if rpm -q appimagelauncher >/dev/null 2>&1; then
  echo "AppImageLauncher is already installed."
else
  echo "Installing AppImageLauncher..."
  sudo dnf install -y appimagelauncher
fi