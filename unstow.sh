#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$(dirname "$(realpath "$0")")"
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <package_name>"
    echo "Example: $0 zsh"
    exit 1
fi

PACKAGE_NAME="$1"

if [ ! -d "$DOTFILES_DIR/$PACKAGE_NAME" ]; then
    echo "Error: Package '$PACKAGE_NAME' not found in '$DOTFILES_DIR'."
    exit 1
fi

if [ "$DOTFILES_DIR" == "$HOME/dotfiles" ]; then
    stow -D "$PACKAGE_NAME"
else
    stow -D -d "$DOTFILES_DIR" -t "$HOME" "$PACKAGE_NAME"
fi

echo "Package '$PACKAGE_NAME' has been unlinked from $HOME"