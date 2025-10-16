#!/bin/bash

set -e

echo "Detecting CPU..."
CPU_VENDOR=$(lscpu | grep -Eo 'AMD|Intel' | head -1)
echo "Detected $CPU_VENDOR"


echo "Listing all VGA and Audio devices"
lspci -nnk | grep -Ei 'VGA|Audio device'
echo


read -p "Enter the device IDs (e.g 1002:15e7 1002:82a9 separated by spaces) you want to passthrough: " PASSTHROUGH_DEVICES


if [[ -z "$PASSTHROUGH_DEVICES" ]]; then
    echo "No devices selected for passthrough :("
    exit 1
else
    echo "You have selected these devices for passthrough: $PASSTHROUGH_DEVICES"
fi
VFIO_ID="vfio-pci.ids=$PASSTHROUGH_DEVICES"


echo "Configuring bootloader for IOMMU..."
if [[ "$CPU_VENDOR" == "AMD" ]]; then
    echo "AMD CPU found"
    BOOT_PARAMS="amd_iommu=on iommu=pt video=efifb:off $VFIO_ID"
elif [[ "$CPU_VENDOR" == "Intel" ]]; then
    echo "Intel CPU found"
    BOOT_PARAMS="intel_iommu=on iommu=pt $VFIO_ID"
else
    echo "Unsupported CPU $CPU_VENDOR"
    exit 1
fi


echo "Configuring bootloader for GPU passthrough"
if efibootmgr -v | grep -qi 'systemd'; then
    LOADER_ENTRY_DIR="/boot/loader/entries/"
    

    echo "Available loader entries:"
    ls -1 "$LOADER_ENTRY_DIR"
 echo
    
    read -p "Enter the name of the loader entry you want to modify (without .conf): " SELECTED_ENTRY
    
    LOADER_ENTRY_FILE="${LOADER_ENTRY_DIR}${SELECTED_ENTRY}.conf"

    
    echo "You selected: $LOADER_ENTRY_FILE"
    echo "Current content:"
    cat "$LOADER_ENTRY_FILE"
    echo
    
    read -p "Do you want to proceed with modifying this file? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Operation cancelled by user"
        exit 1
    fi

    if grep -q "^options" "$LOADER_ENTRY_FILE"; then
        EXISTING_PARAMS=$(grep "^options" "$LOADER_ENTRY_FILE" | sed 's/^options //')
        for PARAM in $BOOT_PARAMS; do
            if ! echo "$EXISTING_PARAMS" | grep -qw "$PARAM"; then
                EXISTING_PARAMS="$EXISTING_PARAMS $PARAM"
            fi
        done
        sudo sed -i "s/^options.*/options $EXISTING_PARAMS/" "$LOADER_ENTRY_FILE"
    else
        echo "options $BOOT_PARAMS" | sudo tee -a "$LOADER_ENTRY_FILE" > /dev/null
    fi

    echo "Systemd-boot config updated in $LOADER_ENTRY_FILE"
    echo "New content:"
    cat "$LOADER_ENTRY_FILE"


echo "Configuring initramfs for VFIO passthrough..."

VFIO_MODULES=("vfio_pci" "vfio" "vfio_iommu_type1")


if command -v mkinitcpio &> /dev/null; then
    echo "Detected mkinitcpio"
    
    INITRD_CONFIG="/etc/mkinitcpio.conf"
    MODULE_LINE="MODULES=(${VFIO_MODULES[*]} amdgpu)"

    if grep -q "^MODULES=" "$INITRD_CONFIG"; then
        sudo sed -i "s/^MODULES=.*/$MODULE_LINE/" "$INITRD_CONFIG"
    else
        echo "$MODULE_LINE" | sudo tee -a "$INITRD_CONFIG" > /dev/null
    fi

    echo "Regenerating mkinitcpio"
    sudo mkinitcpio -P



echo "Enabling and starting libvirt service..."
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

echo "Starting and enabling default libvirt network..."
sudo virsh net-autostart default
sudo virsh net-start default


echo "Shits done reboot playa"

