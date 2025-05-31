#!/bin/zsh
# Enable required COPR repositories for Hyprland and related packages

COPR_REPOS=(
  solopasha/hyprland
  erikreider/SwayNotificationCenter
  errornointernet/packages
  tofik/nwg-shell
)

for repo in "${COPR_REPOS[@]}"; do
  if sudo dnf copr list | grep -q "$repo"; then
    echo "COPR repo $repo is already enabled."
  else
    echo "Enabling COPR repo: $repo"
    sudo dnf copr enable -y "$repo"
  fi
done
