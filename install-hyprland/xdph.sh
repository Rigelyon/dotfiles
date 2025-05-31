#!/bin/zsh
# Install script for xdg-desktop-portal packages for Hyprland (Screen sharing)

typeset -A pkg_groups
pkg_groups=(
  [xdg]="xdg-desktop-portal-hyprland xdg-desktop-portal-gtk"
)

for group in "${(@k)pkg_groups}"; do
  echo "Installing group: $group"
  for pkg in ${(z)pkg_groups[$group]}; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
      echo "$pkg is already installed."
    else
      echo "Installing $pkg..."
      sudo dnf install -y "$pkg"
      if [ $? -eq 0 ]; then
        echo "$pkg installed successfully."
      else
        echo "Failed to install $pkg. Please check your package manager settings."
      fi
    fi
  done
done
