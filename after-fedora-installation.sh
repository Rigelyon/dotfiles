#!/bin/bash

# 1. Upgrade all packages
sudo dnf upgrade --refresh -y

# 2. Enable Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 3. Enable RPM Fusion (free and nonfree)
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 4. Install media codec
sudo dnf install -y libavcodec-freeworld

# 5. Add configuration to /etc/dnf/dnf.conf
DNF_CONF="/etc/dnf/dnf.conf"
sudo grep -q '^fastestmirror=1' $DNF_CONF || echo 'fastestmirror=1' | sudo tee -a $DNF_CONF
sudo grep -q '^max_parallel_downloads=10' $DNF_CONF || echo 'max_parallel_downloads=10' | sudo tee -a $DNF_CONF
