#!/bin/zsh
# Install script for spicetify-cli

# Check if spicetify-cli is already installed
if command -v spicetify >/dev/null 2>&1; then
  echo "Spicetify is already installed."
else
  echo "Installing Spicetify..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
fi

# Find Flatpak Spotify client directory
SPOTIFY_PATH=$(find /var/lib/flatpak/app/com.spotify.Client/ -type d -path '*/files/extra/share/spotify' | head -n 1)
if [ -z "$SPOTIFY_PATH" ]; then
  echo "Spotify client directory not found!"
  exit 1
fi

# Update spotify_path in config-xpui.ini using spicetify config
spicetify config spotify_path "$SPOTIFY_PATH"

# Find prefs path
PREFS_PATH=""
if [ -f "$HOME/.config/spotify/prefs" ]; then
  PREFS_PATH="$HOME/.config/spotify/prefs"
elif [ -f "$HOME/.var/app/com.spotify.Client/config/spotify/prefs" ]; then
  PREFS_PATH="$HOME/.var/app/com.spotify.Client/config/spotify/prefs"
fi
if [ -z "$PREFS_PATH" ]; then
  echo "Spotify prefs file not found!"
  exit 1
fi

# Update prefs_path in config-xpui.ini using spicetify config
spicetify config prefs_path "$PREFS_PATH"

# Set read/write permissions
sudo chmod a+wr "$SPOTIFY_PATH"
sudo chmod a+wr -R "$SPOTIFY_PATH/Apps"

spicetify apply
