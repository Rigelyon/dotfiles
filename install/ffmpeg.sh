#!/bin/zsh
# Install script for ffmpeg

if command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is already installed."
else
  echo "Installing ffmpeg..."
  sudo dnf install -y ffmpeg
  if [ $? -eq 0 ]; then
    echo "ffmpeg installed successfully."
  else
    echo "Failed to install ffmpeg. Please check your package manager settings."
  fi
fi
