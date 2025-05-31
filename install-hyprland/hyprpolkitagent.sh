#!/bin/zsh
# Install script for hyprpolkitagent (Hyprland's Polkit Agent)

if rpm -q hyprpolkitagent >/dev/null 2>&1; then
  echo "hyprpolkitagent is already installed."
else
  echo "Installing hyprpolkitagent..."
  sudo dnf install -y hyprpolkitagent
  if [ $? -eq 0 ]; then
    echo "hyprpolkitagent installed successfully."
  else
    echo "Failed to install hyprpolkitagent. Please check your package manager settings."
  fi
fi
