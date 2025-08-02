#!/bin/bash

set -e

echo "Checking for IOMMU..."
if dmesg | grep -qi "IOMMU: DETECTED"; then
    echo "IOMMU is detected"
else
    echo "IOMMU is not enabled"
    echo "Exiting script"
    exit 1
fi


echo "Detecting CPU..."
CPU_VENDOR=$(lscpu | grep -Eo 'AMD|Intel' | head -1)
echo "Detected $CPU_VENDOR"


echo "Listing all VGA and Audio devices"
lspci -nnk | grep -Ei 'VGA|Audio device'
echo


read -p "Enter the device IDs (e.g., 1002:15e7 1002:82a9 separated by spaces) you want to passthrough: " PASSTHROUGH_DEVICES


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


if efibootmgr -v | grep -qi 'systemd'; then
    echo "Configuring systemd-boot..."
    LOADER_ENTRY_DIR="/boot/loader/entries/"
    
    DEFAULT_ENTRY=$(bootctl list | grep -E "^\*" | awk '{print $2}' | head -1)
    if [[ -z "$DEFAULT_ENTRY" ]]; then
        echo "Error couldnt find default loader entry"
        exit 1
    fi

    LOADER_ENTRY_FILE="${LOADER_ENTRY_DIR}${DEFAULT_ENTRY}.conf"
    
    if [[ ! -f "$LOADER_ENTRY_FILE" ]]; then
        echo "Error loader entry file ($LOADER_ENTRY_FILE) does not exist"
        exit 1
    fi

    sudo cp "$LOADER_ENTRY_FILE" "${LOADER_ENTRY_FILE}.bak"

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

    echo "Systemd-boot config updated in $LOADER_ENTRY_FILE."
else
    echo "Configuring GRUB"
    GRUB_CONFIG="/etc/default/grub"
    if grep -q "^GRUB_CMDLINE_LINUX=" "$GRUB_CONFIG"; then
        EXISTING_PARAMS=$(grep "^GRUB_CMDLINE_LINUX=" "$GRUB_CONFIG" | sed 's/^GRUB_CMDLINE_LINUX="//' | sed 's/"$//')
        for PARAM in $BOOT_PARAMS; do
            if ! echo "$EXISTING_PARAMS" | grep -qw "$PARAM"; then
                EXISTING_PARAMS="$EXISTING_PARAMS $PARAM"
            fi
        done
        sudo sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"$EXISTING_PARAMS\"/" "$GRUB_CONFIG"
    else
        echo "GRUB_CMDLINE_LINUX=\"$BOOT_PARAMS\"" | sudo tee -a "$GRUB_CONFIG" > /dev/null
    fi
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi



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

elif command -v dracut &> /dev/null; then
    echo "Detected dracut"

    DRACUT_CONF="/etc/dracut.conf.d/10-vfio.conf"

    {
        echo "add_drivers+=\" ${VFIO_MODULES[*]} amdgpu \""
        echo "force_drivers+=\" ${VFIO_MODULES[*]} amdgpu \""
    } | sudo tee "$DRACUT_CONF" > /dev/null

    echo "egenerating dracut"
    sudo dracut -f

elif command -v update-initramfs &> /dev/null; then
    echo "Detected modprobe"

    INITRD_MODULES="/etc/modprobe.d/vfio.conf"
    MODPROBE_MODULES=("options vfio-pci ids=$PASSTHROUGH_DEVICES")
    
    for mod in "${MODPROBE_MODULES[@]}" "amdgpu"; do
        if ! grep -Fxq "$mod" "$INITRD_MODULES"; then
            echo "$mod" | sudo tee -a "$INITRD_MODULES" > /dev/null
        fi
    done

    echo "Regenerating initramfs"
    sudo update-initramfs -u -k all

else
    echo "Could not detect supported initramfs tool (mkinitcpio, dracut, initramfs-tools)"
    exit 1
fi


echo "Shits done reboot playa"

