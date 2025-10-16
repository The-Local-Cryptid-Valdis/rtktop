#!/bin/bash

set -euo pipefail



OS_ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')


declare -a ARCH_PACKAGES=(
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
    flatpak
    bubblewrap-suid
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



case "$OS_ID" in
    arch)
        echo "Detected Arch Linux"
        sudo pacman -Syu --noconfirm "${ARCH_PACKAGES[@]}"
        ;;
    *)
        echo "Unsupported distribution: $OS_ID"
        exit 1
        ;;
esac



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
  "org.kde.kget"
)

for APP in "${FLATPAKS[@]}"; do
    echo "Installing $APP"
    flatpak install -y flathub "$APP"
done



SRC_DIR="$HOME/rtktop"
DEST_DIR="$HOME"


mkdir -p "$DEST_DIR"

rsync -a "$SRC_DIR/Documents" "$DEST_DIR"

rsync -a "$SRC_DIR/Pictures" "$DEST_DIR"

sudo cp "$SRC_DIR/default.conf" "/usr/lib/sddm/sddm.conf.d"

echo alias passgpu='bash ~./rtktop/gpu-passthrough.sh' >> .bashrc

echo alias swaptheme='bash ~/rtktop/Documents/swaptheme.sh' >> .bashrc

#call theme script before saying its done instead of running this then running the theme script just to start with a theme
echo "Shits done"
