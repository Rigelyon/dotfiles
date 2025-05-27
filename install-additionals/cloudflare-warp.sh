#!/bin/zsh
# Install script for Cloudflare WARP

if command -v warp-cli >/dev/null 2>&1; then
  echo "Cloudflare WARP is already installed."
else
  echo "Installing Cloudflare WARP..."
  sudo yum install -y cloudflare-warp
  if [ $? -eq 0 ]; then
    echo "Cloudflare WARP installed successfully."
    echo "To start using it, run 'warp-cli register' and follow the instructions."
  else
    echo "Failed to install Cloudflare WARP. Please check your package manager settings."
  fi
fi