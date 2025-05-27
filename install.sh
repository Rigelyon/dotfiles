#!/bin/zsh
# install.sh - Run all install scripts in the install directory with confirmation for each

INSTALL_DIR="$(dirname "$0")/install"

# Ensure all scripts in the install directory are executable
chmod +x "$INSTALL_DIR"/*

if [ ! -d "$INSTALL_DIR" ]; then
  echo "Install directory not found: $INSTALL_DIR"
  exit 1
fi

confirm_all=false
if [[ "$1" == "-y" ]]; then
  confirm_all=true
fi

for script in "$INSTALL_DIR"/*; do
  if [ -f "$script" ] && [ -x "$script" ]; then
    app_name=$(basename "$script")
    extra_msg=""
    if [[ $app_name == spotify* ]]; then
      extra_msg=" (Needed for Spicetify)"
    fi
    if $confirm_all; then
      REPLY="y"
    else
      read -q "REPLY?Do you want to install $app_name$extra_msg? [y/N] "
      echo
    fi
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Installing $app_name..."
      "$script"
    else
      echo "Skipping $app_name."
    fi
  fi
done

echo "All install scripts finished."
