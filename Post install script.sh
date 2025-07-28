#!/bin/bash

set -euo pipefail

mkdir Downloads
mv rtktop Downloads/


echo "Installing packages with pacman"
sudo pacman -Syu \
    bash-completion \
    grim \
    w3m \
    imagemagick \
    slurp \
    pavucontrol \
    btop \
    unzip \
    flatpak \
    bubblewrap-suid \
    uwsm \
    waybar \
    hyprpaper \
    polkit \
    polkit-kde-agent \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    kitty \
    ristretto \
    mousepad \
    thunar \
    gvfs \
    rsync \
    gnome-disk-utility \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    adobe-source-han-sans-jp-fonts \
    adobe-source-han-serif-jp-fonts \
    ttf-firacode-nerd \
    ttf-font-awesome \
    otf-font-awesome \
    breeze \
    breeze-gtk \
    networkmanager \
    network-manager-applet \
    networkmanager-openvpn \
    networkmanager-qt5 \
    networkmanager-qt \
    nm-connection-editor \
    openresolv \
    wireguard-tools \
    firewalld \
    qemu-desktop \
    libvirt \
    edk2-ovmf \
    virt-manager \
    dnsmasq \
    mpv




echo "Enabling and starting firewalld"
sudo systemctl enable --now firewalld.service

PRESET_FILE="/usr/lib/systemd/system-preset/90-systemd.preset"
if ! grep -q "^enable firewalld.service" "$PRESET_FILE"; then
    echo "Adding firewalld to system preset"
    echo "enable firewalld.service" | sudo tee -a "$PRESET_FILE"
fi

echo "Applying firewalld preset"
sudo systemctl preset firewalld.service

echo "Setting firewalld default zone and allowed ports/services"
sudo firewall-cmd --set-default-zone=drop

# Adds http,https,dns and dhcp to allow list
PORTS=(80/tcp 443/tcp 53/udp 67/udp 68/udp)
for PORT in "${PORTS[@]}"; do
    echo "Adding port $PORT to drop zone"
    sudo firewall-cmd --zone=drop --add-port=$PORT --permanent
done

sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload




echo "Locking root account"
sudo passwd -l root




echo "Installing Flatpak apps"
FLATPAKS=(
  "io.gitlab.librewolf-community"
  "dev.vencord.Vesktop"
  "com.vscodium.codium"
  "org.gimp.GIMP"
)

for APP in "${FLATPAKS[@]}"; do
    echo "Installing $APP"
    flatpak install -y flathub "$APP"
done



SRC_DIR="$HOME/Downloads/rtktop"
DEST_DIR="/home/rtk/"


mkdir -p "$DEST_DIR"

echo "Copying Documents..."
rsync -a "$SRC_DIR/Documents" "$DEST_DIR"

echo "Copying Pictures..."
rsync -a "$SRC_DIR/Pictures" "$DEST_DIR"


echo "Shits done"
