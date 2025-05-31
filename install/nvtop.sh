#!/bin/zsh
# Install script for nvtop (NVIDIA GPU monitoring tool)

if command -v nvtop >/dev/null 2>&1; then
  echo "nvtop is already installed."
else
  echo "Installing nvtop..."
  sudo dnf install -y nvtop
  if [ $? -eq 0 ]; then
    echo "nvtop installed successfully."
  else
    echo "Failed to install nvtop. Please check your package manager settings."
  fi
fi
