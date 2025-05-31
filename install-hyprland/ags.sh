#!/bin/zsh
# Install script for AGS (Aylur's Gtk Shell) dependencies

typeset -A pkg_groups
pkg_groups=(
  [ags]="cmake typescript nodejs-npm meson gjs gjs-devel gobject-introspection gobject-introspection-devel gtk3-devel gtk-layer-shell upower NetworkManager pam-devel pulseaudio-libs-devel libdbusmenu-gtk3 libsoup3"
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
