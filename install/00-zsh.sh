#!/bin/bash
# Install script for zsh and oh-my-zsh

if command -v zsh >/dev/null 2>&1; then
  echo "Zsh is already installed."
else
  echo "Installing Zsh..."
  sudo dnf install -y zsh
fi

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh is already installed."
fi

# Install powerlevel10k if not present
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Linking local powerlevel10k..."
  ln -sfn "$(dirname "$0")/../zsh/powerlevel10k" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "powerlevel10k is already installed."
fi
