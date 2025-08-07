#!/bin/bash

RICE_DIR="$HOME/Documents/Rices"
CONFIG_DIR="$HOME/.config"
COMPONENTS=("waybar" "sddm" "hypr" "fastfetch")
BASHRC_FILE="$HOME/.bashrc"

if [ -z "$1" ]; then
    echo "Select a rice to apply:"
    select RICE_NAME in $(ls "$RICE_DIR"); do
        if [ -n "$RICE_NAME" ]; then
            break
        fi
    done
else
    RICE_NAME="$1"
fi

TARGET_RICE="$RICE_DIR/$RICE_NAME"

if [ ! -d "$TARGET_RICE" ]; then
    echo "Error: Rice '$RICE_NAME' does not exist in $RICE_DIR!"
    exit 1
fi

echo "Switching to rice: $RICE_NAME"

for COMPONENT in "${COMPONENTS[@]}"; do
    TARGET_COMPONENT="$TARGET_RICE/$COMPONENT"
    CONFIG_COMPONENT="$CONFIG_DIR/$COMPONENT"

    if [ -d "$TARGET_COMPONENT" ]; then
        echo "Updating $COMPONENT..."
        ln -sf "$TARGET_COMPONENT" "$CONFIG_COMPONENT"
    else
        echo "Warning: $COMPONENT not found in $TARGET_RICE, skipping..."
    fi
done


TARGET_BASHRC="$TARGET_RICE/.bashrc"
if [ -f "$TARGET_BASHRC" ]; then
    echo "Updating .bashrc..."
    cp "$TARGET_BASHRC" "$BASHRC_FILE"
    source "$BASHRC_FILE"
else
    echo "Warning: No .bashrc file found in $TARGET_RICE, skipping..."
fi

echo "Restarting services..."
killall waybar 2>/dev/null && waybar &
hyprpaper --config "$CONFIG_DIR/hypr/hyprpaper.conf" &
sddm --reconfigure 2>/dev/null

echo "Rice '$RICE_NAME' applied successfully!"