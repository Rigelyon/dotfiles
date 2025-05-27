#!/bin/zsh
# Install script for Zen Browser

if command -v zen-browser >/dev/null 2>&1; then
  echo "Zen Browser is already installed."
else
  echo "Installing Zen Browser..."
  sudo flatpak install flathub app.zen_browser.zen
    if [ $? -eq 0 ]; then
        echo "Zen Browser installed successfully."
    else
        echo "Failed to install Zen Browser. Please check your Flatpak settings."
    fi