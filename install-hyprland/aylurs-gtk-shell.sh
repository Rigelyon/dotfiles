#!/bin/zsh
# Install script for aylurs-gtk-shell (Desktop Environment Shell)

if command -v aylurs-gtk-shell >/dev/null 2>&1; then
  echo "aylurs-gtk-shell is already installed."
else
  echo "Installing aylurs-gtk-shell..."
  sudo dnf install -y aylurs-gtk-shell
  if [ $? -eq 0 ]; then
    echo "aylurs-gtk-shell installed successfully."
  else
    echo "Failed to install aylurs-gtk-shell. Please check your package manager settings."
  fi
fi
