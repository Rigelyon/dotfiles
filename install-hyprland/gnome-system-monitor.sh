#!/bin/zsh
# Install script for gnome-system-monitor (used to monitor system resources)

if command -v gnome-system-monitor >/dev/null 2>&1; then
  echo "gnome-system-monitor is already installed."
else
  echo "Installing gnome-system-monitor..."
  sudo dnf install -y gnome-system-monitor
  if [ $? -eq 0 ]; then
    echo "gnome-system-monitor installed successfully."
  else
    echo "Failed to install gnome-system-monitor. Please check your package manager settings."
  fi
fi
