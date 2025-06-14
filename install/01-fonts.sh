#!/bin/zsh
# Install script for JetBrains Mono Nerd Font and other fonts

FONT_NAME="JetBrainsMonoNerdFont"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

if [ -d "$FONT_DIR" ] && ls "$FONT_DIR"/*.ttf >/dev/null 2>&1; then
  echo -e "JetBrains Mono Nerd Font already appears to be installed in $FONT_DIR."
  echo -e "Skipping font installation."
else
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
fi

# Install additional font packages
fonts=(
  fontawesome-fonts-all
  google-noto-color-emoji-fonts
  google-noto-emoji-fonts
)

for fontpkg in "${fonts[@]}"; do
  if ! rpm -q "$fontpkg" >/dev/null 2>&1; then
    echo "Installing $fontpkg..."
    sudo dnf install -y "$fontpkg"
  else
    echo "$fontpkg is already installed."
  fi
done
