#!/bin/bash

# Check the number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_dotfiles> <package_name>"
    echo "Example: $0 ~/Repository/dotfiles zsh"
    exit 1
fi

DOTFILES_DIR="$1"
PACKAGE_NAME="$2"

# Check if the dotfiles directory and package exist
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Dotfiles directory '$DOTFILES_DIR' not found."
    exit 1
fi

if [ ! -d "$DOTFILES_DIR/$PACKAGE_NAME" ]; then
    echo "Error: Package '$PACKAGE_NAME' not found in '$DOTFILES_DIR'."
    exit 1
fi

# Run stow
stow -d "$DOTFILES_DIR" -t "$HOME" "$PACKAGE_NAME"
echo "Package '$PACKAGE_NAME' has been stowed to $HOME"
