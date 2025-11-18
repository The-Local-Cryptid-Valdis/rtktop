#!/bin/bash

set -euo pipefail



declare -a PACKAGES=(
    bash-completion
    grim
    w3m
    steam
    flameshot
    wl-clipboard
    imagemagick
    slurp
    pavucontrol
    btop
    unzip
    bubblewrap-suid
    flatpak
    uwsm
    waybar
    hyprpaper
    polkit
    polkit-kde-agent
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    kitty
    ristretto
    mousepad
    thunar
    gvfs
    rsync
    gnome-disk-utility
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    adobe-source-han-sans-jp-fonts
    adobe-source-han-serif-jp-fonts
    ttf-firacode-nerd
    ttf-font-awesome
    otf-font-awesome
    breeze
    breeze-gtk
    networkmanager
    network-manager-applet
    networkmanager-openvpn
    networkmanager-qt5
    networkmanager-qt
    nm-connection-editor
    openresolv
    wireguard-tools
    firewalld
    qemu-desktop
    libvirt
    edk2-ovmf
    virt-manager
    dnsmasq
    mpv
    fastfetch
)


        sudo pacman -Syu "${PACKAGES[@]}"



sudo systemctl enable firewalld.service
sudo systemctl start firewalld.service

sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --reload


sudo passwd -l root


FLATPAKS=(
  "io.gitlab.librewolf-community"
  "dev.vencord.Vesktop"
  "com.vscodium.codium"
  "org.gimp.GIMP"
  "org.kde.kget"
)

for APP in "${FLATPAKS[@]}"; do
    echo "Installing $APP"
    flatpak install -y flathub "$APP"
done



mkdir -p "$HOME"

rsync -a "$HOME/rtktop/Documents" "$HOME"

rsync -a "$HOME/rtktop/Pictures" "$HOME"

sudo cp "$HOME/rtktop/default.conf" "/usr/lib/sddm/sddm.conf.d/"
sudo cp -r "Documents/sddm-themes/*" "/usr/share/sddm/themes/"
sudo mkdir /etc/sddm.conf.d/
sudo cp "rtktop/sddm.conf" "/etc/sddm.conf.d" 

sudo pacman -Rs dolphin firefox

echo alias passgpu='bash ~./rtktop/gpu-passthrough.sh' >> .bashrc
echo alias swaptheme='bash ~/rtktop/Documents/swaptheme.sh' >> .bashrc

#Calls theme script
./Documents/swaptheme.sh

echo "Shits done, Run "swaptheme" to apply themes"
