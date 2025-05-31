#!/usr/bin/env bash
# Install NVIDIA drivers and configure GRUB

PACKAGES=(
  akmod-nvidia
  xorg-x11-drv-nvidia-cuda
  libva
  libva-nvidia-driver
)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if ! rpm -q "$pkg" >/dev/null 2>&1; then
    MISSING+=("$pkg")
  else
    echo "$pkg is already installed."
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "Installing missing packages: ${MISSING[*]}"
  sudo dnf install -y "${MISSING[@]}"
else
  echo "All packages are already installed."
fi

# Add additional options to GRUB_CMDLINE_LINUX if not present
GRUB_FILE="/etc/default/grub"
additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 nvidia_drm.fbdev=1"

if grep -q "$additional_options" "$GRUB_FILE"; then
  echo "GRUB options already set."
else
  echo "Adding NVIDIA options to GRUB_CMDLINE_LINUX..."
  sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s|\"$| $additional_options\"|" "$GRUB_FILE"
  echo "Updating grub configuration..."
  if [ -d /sys/firmware/efi ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
fi

echo "NVIDIA installation and configuration complete."
