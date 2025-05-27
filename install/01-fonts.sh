#!/bin/zsh
# Install script for JetBrains Mono Nerd Font

FONT_NAME="JetBrainsMonoNerdFont"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

mkdir -p "$FONT_DIR"
echo "Downloading JetBrains Mono Nerd Font..."
curl -L -o /tmp/JetBrainsMono.zip "$FONT_URL"
unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
rm /tmp/JetBrainsMono.zip

# Refresh font cache
if command -v fc-cache >/dev/null 2>&1; then
  echo "Refreshing font cache..."
  fc-cache -fv "$FONT_DIR"
fi

echo "JetBrains Mono Nerd Font installed to $FONT_DIR."
