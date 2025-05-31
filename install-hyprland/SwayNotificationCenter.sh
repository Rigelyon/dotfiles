#!/bin/zsh
# Install script for SwayNotificationCenter (a notification center for Sway and Hyprland)

if command -v SwayNotificationCenter >/dev/null 2>&1; then
  echo "SwayNotificationCenter is already installed."
else
  echo "Installing SwayNotificationCenter..."
  sudo dnf install -y SwayNotificationCenter
  if [ $? -eq 0 ]; then
    echo "SwayNotificationCenter installed successfully."
  else
    echo "Failed to install SwayNotificationCenter. Please check your package manager settings."
  fi
fi
