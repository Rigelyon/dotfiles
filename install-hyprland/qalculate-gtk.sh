#!/bin/zsh
# Install script for qalculate-gtk (Advanced Calculator)

if command -v qalculate-gtk >/dev/null 2>&1; then
  echo "qalculate-gtk is already installed."
else
  echo "Installing qalculate-gtk..."
  sudo dnf install -y qalculate-gtk
  if [ $? -eq 0 ]; then
    echo "qalculate-gtk installed successfully."
  else
    echo "Failed to install qalculate-gtk. Please check your package manager settings."
  fi
fi
