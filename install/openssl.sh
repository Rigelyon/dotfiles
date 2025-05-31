#!/bin/zsh
# Install script for openssl (a robust, full-featured toolkit for general-purpose cryptography and SSL/TLS)

if command -v openssl >/dev/null 2>&1; then
  echo "openssl is already installed."
else
  echo "Installing openssl..."
  sudo dnf install -y openssl
  if [ $? -eq 0 ]; then
    echo "openssl installed successfully."
  else
    echo "Failed to install openssl. Please check your package manager settings."
  fi
fi
