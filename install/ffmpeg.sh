#!/bin/zsh
# Install script for ffmpeg

if command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is already installed."
else
  echo "Installing ffmpeg..."
  sudo dnf install -y ffmpeg
fi
