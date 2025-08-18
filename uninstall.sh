#!/bin/bash

set -euo pipefail

echo "🗑️  Uninstalling Nezuko KDE theme..."

# KDE user dirs
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
COLOR_DIR="$HOME/.local/share/color-schemes"

# Theme names
CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko"
COLOR_NAME="Nezuko.colors"

# Function: ensure correct ownership (fixes leftover root-owned files)
fix_ownership() {
    local path=$1
    if [ -e "$path" ]; then
        if [ "$(stat -c %U "$path")" != "$USER" ]; then
            echo "⚠️  Fixing ownership for $path"
            sudo chown -R "$USER":"$USER" "$path"
        fi
    fi
}

# Function to uninstall safely
remove_theme_component() {
    local dest=$1
    local name=$2

    if [ -e "$dest" ]; then
        echo "➡️ Removing $name..."
        fix_ownership "$dest"
        rm -rf "$dest"
    else
        echo "ℹ️  $name not found, skipping."
    fi
}

# Remove components
remove_theme_component "$CURSOR_DIR/$CURSOR_NAME" "cursors"
remove_theme_component "$ICON_DIR/$ICON_NAME" "icons"
remove_theme_component "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
remove_theme_component "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"
remove_theme_component "$COLOR_DIR/$COLOR_NAME" "color scheme"


echo "✅ Uninstallation complete!"
