# Dotfiles with GNU Stow

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

## Usage with Scripts

Script are used to simplified the usage of the command. Dynamically check if the dotfiles directory is in the home directory or not

### 1. Stow (Create Symlink)

Run:

```bash
bash stow.sh <package_name>
```

Example:

```bash
bash stow.sh hypr
```

This script will create a symlink from `~/Repository/dotfiles/hypr/.config/hypr` to `~/.config/hypr` for the Hyprland package.

### 2. Unstow (Remove Symlink)

Run:

```bash
bash unstow.sh <package_name>
```

Example:

```bash
bash unstow.sh hypr
```

This script will remove the symlink `~/.config/hypr` created by stow.

## Usage Without Scripts

If you prefer not to use the stow.sh and unstow.sh scripts, you can use the stow command directly from the terminal.

### 1. If the dotfiles folder is in the home directory (`~/dotfiles`)

Navigate to the dotfiles folder:

```bash
cd ~/dotfiles
```

To create symlinks:

```bash
stow bash
stow hypr
stow nvim
```

To remove symlinks:

```bash
stow -D bash
stow -D hypr
stow -D nvim
```

Explanation:
- `-D` is used to remove symlinks previously created by stow.

### 2. If the dotfiles folder is outside the home directory (e.g., `~/Repository/dotfiles`)

Navigate to the dotfiles folder:

```bash
cd ~/Repository/dotfiles
```

To create symlinks:

```bash
stow -d . -t ~ bash # '.' is the dotfiles directory, 'bash' is the package name
stow -d . -t ~ hypr
stow -d . -t ~ nvim
```

To remove symlinks:

```bash
stow -D -d . -t ~ bash  # '.' is the dotfiles directory, 'bash' is the package name
stow -D -d . -t ~ hypr
stow -D -d . -t ~ nvim
```

Explanation:
- `-D` is used to remove symlinks previously created by stow.
- `-d` specifies the directory where the package is located.
- `-t` specifies the target directory where the symlink will be created (`~` or home).

### Tips
- Ensure there are no conflicting files in the target location (`~/.bashrc`, etc.), as symlinks will fail if such files are exist.

### Disclaimer

This repository is intended for **personal use only**. Some configuration files or scripts included here may have been copied or adapted from third-party sources whose licenses may have rules about how the content can be used, shared, or changed. As such, redistributing or reusing the contents of this repository without proper permission may violate the original licenses. You are advised not to reuse or share anything from this repository unless you are certain you have the right to do so.
