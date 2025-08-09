#!/bin/bash

RICE_DIR="$HOME/Documents/Rices"
CONFIG_DIR="$HOME/.config"
COMPONENTS=("waybar" "hypr" "sddm" "fastfetch")
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

    echo "Updating $COMPONENT"

    if [ -e "$CONFIG_COMPONENT" ] || [ -L "$CONFIG_COMPONENT" ]; then
        rm -rf "$CONFIG_COMPONENT"
    fi

    ln -s "$TARGET_COMPONENT" "$CONFIG_COMPONENT"
done


TARGET_BASHRC="$TARGET_RICE/.bashrc"
if [ -f "$TARGET_BASHRC" ]; then
    echo "Updating .bashrc..."
    cp "$TARGET_BASHRC" "$BASHRC_FILE"
    source "$BASHRC_FILE"
else
    echo "Warning: No .bashrc file found in $TARGET_RICE, skipping"
fi

echo "Restarting services"


killall waybar >/dev/null 2>&1 && nohup waybar >/dev/null 2>&1 &

killall hyprpaper >/dev/null 2>&1 && nohup hyprpaper >/dev/null 2>&1 &


echo "Rice '$RICE_NAME' applied successfully!"




