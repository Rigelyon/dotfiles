#!/bin/zsh
# Revert hypr config to previous backup
set -e

# Paths
HYPR_HOME="$HOME/.config/hypr"
BACKUP_HOME="$HOME/.config/hypr.backup-dotfiles"

# Unstow config
./unstow.sh hyprland

# Remove current hypr config if exists (symlink or folder)
if [ -L "$HYPR_HOME" ] || [ -d "$HYPR_HOME" ]; then
    echo "Removing current hypr config at $HYPR_HOME"
    rm -rf "$HYPR_HOME"
fi

# Restore backup if exists
if [ -d "$BACKUP_HOME" ]; then
    echo "Restoring backup to $HYPR_HOME"
    mv "$BACKUP_HOME" "$HYPR_HOME"
    echo "Hypr config reverted to backup."
else
    echo "No backup found to restore."
fi
