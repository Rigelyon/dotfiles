#!/usr/bin/env bash
# Install script for Discord via RPM

# Check if Discord is installed via RPM
if rpm -q discord >/dev/null 2>&1; then
  echo "Discord is already installed."
else
  echo "Installing Discord..."
  sudo dnf install -y discord
fi