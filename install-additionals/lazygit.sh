#!/bin/zsh
# Install script for lazygit (terminal UI for Git)

if command -v lazygit >/dev/null 2>&1; then
  echo "lazygit is already installed."
else
  echo "Installing lazygit..."
  sudo dnf copr enable atim/lazygit -y
  sudo dnf install lazygit -y
fi