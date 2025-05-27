#!/bin/zsh
# Install script for VLC (media player)

if command -v vlc >/dev/null 2>&1; then
  echo "VLC is already installed."
else
  echo "Installing VLC..."
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf install -y vlc
fi
