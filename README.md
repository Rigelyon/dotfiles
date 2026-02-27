# Dotfiles with GNU Stow

These dotfiles are designed for the custom Bazzite image: [bazzite-hyprland](https://github.com/Rigelyon/bazzite-hyprland).

This repository is used to manage and back up configuration files (dotfiles) using [GNU Stow](https://www.gnu.org/software/stow/). Stow creates symlinks from the configuration files in the repository to the locations used by the system/application, such as `~/.bashrc`, `~/.gitconfig`, and others.

## Directory Structure

Each subfolder in this repository represents a dotfiles _package_. The folder name should represent the program, for example:

```bash
dotfiles/
├── bash/
│   └── .bashrc
├── zsh/
│   └── .zshrc
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.vim
│           └── lua/
├── hypr/
│   └── .config/
│       └── hypr/
│           └── hyprland.conf
```

The files and folders inside each package should reflect their final positions in the system (e.g., `~/.bashrc`, `~/.config/nvim/init.vim`, etc.).

## Usage

This repository uses a single interactive script, `setup.sh`, to manage configurations.

### Install / Restore

Run the setup script:

```bash
./setup.sh
```

You will be presented with a menu:

1.  **Install/Update Configs**:
    - Checks if the corresponding program is installed on your system, separated into packages with configs and dependencies only.
    - Checks config link status (LINKED / PARTIAL / NOT LINKED).
    - If a conflict is found (target file already exists), you can choose to:
        - **Backup**: Renames the existing file with a `.dotfiles-backup` suffix and links the new config.
        - **Overwrite**: Deletes the existing file and links the new config.
        - **Skip**: Skips this package.
    - Uses GNU Stow to create symlinks.

2.  **Restore Configs**:
    - Checks for backups created by this script (`*.dotfiles-backup`).
    - Gives you the option to restore them to their original location.

3.  **Add New Config**:
    - Interactively add a new configuration package to the repository.
    - Prompts for package name, installation check command, and file path relative to `$HOME`.
    - Automatically creates the correct directory structure.
    - Updates `dependencies.conf` and `README.md` automatically.
    - Example: Adding `yazi` config at `.config/yazi` creates `yazi/.config/yazi/`

4.  **Delete Config**:
    - Lists all config packages with their link status.
    - Detects orphaned entries in `dependencies.conf` that have no matching directory.
    - **Unlink only**: Removes symlinks (verifies if actually linked first).
    - **Full remove**: Unlinks, deletes directory, and cleans up `dependencies.conf` and `README.md`.

5.  **Exit**.

### Requirements

- **GNU Stow**: Must be installed (`sudo dnf install stow` or equivalent).
- **Bash**: The script is written in Bash.

## Dependencies

These dotfiles only checks these following packages. For the installation, use [bazzite-hyprland](https://github.com/Rigelyon/bazzite-hyprland).

Package to check:

- **bash**
- **bat**
- **btop**
- **fastfetch**
- **fd**
- **fzf**
- **git**
- **hypr**
- **hypr** (Hyprland)
- **kitty**
- **lazygit**
- **lsd**
- **micro**
- **mpv**
- **nvim** (Neovim)
- **ripgrep**
- **rofi**
- **starship**
- **swaync**
- **vlc**
- **waybar**
- **wlogout**
- **yazi**
- **zoxide**
- **zsh**

### Tips
- Ensure there are no conflicting files in the target location if you want a clean install, or use the **Backup** option in the script.

### Disclaimer

This repository is intended for **personal use only**. Some configuration files or scripts included here may have been copied or adapted from third-party sources whose licenses may have rules about how the content can be used, shared, or changed. As such, redistributing or reusing the contents of this repository without proper permission may violate the original licenses. You are advised not to reuse or share anything from this repository unless you are certain you have the right to do so.
