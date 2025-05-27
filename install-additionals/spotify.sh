#!/bin/bash

# Uninstall Spotify if installed via Snap
echo "Checking for Snap Spotify installation..."
if snap list | grep -q '^spotify\s'; then
    echo "Snap Spotify found. Removing..."
    sudo snap remove spotify
else
    echo "No Snap Spotify installation found."
fi

# Install Spotify
if command -v flatpak >/dev/null 2>&1; then
    echo "Trying to install Spotify via Flatpak..."
    flatpak install -y flathub com.spotify.Client
    exit 0
fi
