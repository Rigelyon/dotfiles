#!/bin/zsh
# Backup and apply hypr config from dotfiles using stow
set -e

# Paths
HYPR_HOME="$HOME/.config/hypr"
BACKUP_HOME="$HOME/.config/hypr.backup-dotfiles"

# Backup if not already backed up
if [ -d "$HYPR_HOME" ] && [ ! -d "$BACKUP_HOME" ]; then
    echo "Backing up existing hypr config to $BACKUP_HOME"
    mv "$HYPR_HOME" "$BACKUP_HOME"
fi

# Apply config using stow.sh
./stow.sh hyprland

echo "Hypr config applied from dotfiles."
