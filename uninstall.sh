#!/bin/bash

set -euo pipefail

echo "🗑️  Uninstalling Nezuko KDE theme..."

# KDE user dirs
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"  # Changed to system-wide
COLOR_DIR="$HOME/.local/share/color-schemes"
KONSOLE_DIR="$HOME/.local/share/konsole"
LOCAL_BIN="$HOME/.local/bin"

# Theme names
CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko"
COLOR_NAME="Nezuko.colors"
KONSOLE_NAME="NezukoKamado.colorscheme"

# Function: fix ownership safely
fix_ownership() {
    local path=$1
    if [ -e "$path" ]; then
        echo "⚠️  Fixing ownership for $path"
        sudo chown -R "$(whoami)":"$(whoami)" "$path"
    fi
}

# Function: remove safely
remove_theme_component() {
    local dest=$1
    local name=$2

    if [ -e "$dest" ]; then
        echo "➡️ Removing $name..."
        fix_ownership "$dest"
        sudo rm -rf "$dest"
    else
        echo "ℹ️  $name not found, skipping."
    fi
}

# Function: remove system component safely
remove_system_theme_component() {
    local dest=$1
    local name=$2

    if [ -e "$dest" ]; then
        echo "➡️ Removing $name (system-wide)..."
        sudo rm -rf "$dest"
    else
        echo "ℹ️  $name not found, skipping."
    fi
}

# Remove components
remove_theme_component "$CURSOR_DIR/$CURSOR_NAME" "cursors"
remove_theme_component "$ICON_DIR/$ICON_NAME" "icons"
remove_theme_component "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
remove_system_theme_component "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"  # Changed to system-wide removal
remove_theme_component "$COLOR_DIR/$COLOR_NAME" "color scheme"
remove_theme_component "$KONSOLE_DIR/$KONSOLE_NAME" "Konsole color scheme"

# Reset Konsole profiles to default color scheme
if compgen -G "$KONSOLE_DIR/*.profile" > /dev/null; then
    echo "➡️ Resetting Konsole profiles to default color scheme..."
    for profile in "$KONSOLE_DIR"/*.profile; do
        if grep -q "^ColorScheme=NezukoKamado" "$profile"; then
            sed -i 's/^ColorScheme=NezukoKamado/ColorScheme=Breeze/g' "$profile"
        fi
    done
fi

# Remove standalone splash if installed
SPLASH_BIN="$LOCAL_BIN/nezuko-splash"
if [ -f "$SPLASH_BIN" ]; then
    echo "➡️ Removing standalone splash..."
    rm -f "$SPLASH_BIN"
fi

# Remove splash resources
SPLASH_RESOURCES="$LOCAL_BIN/nezuko-splash-resources"
if [ -d "$SPLASH_RESOURCES" ]; then
    echo "➡️ Removing splash resources..."
    rm -rf "$SPLASH_RESOURCES"
fi

# Remove autostart entry
AUTOSTART_FILE="$HOME/.config/autostart/nezuko-splash.desktop"
if [ -f "$AUTOSTART_FILE" ]; then
    echo "➡️ Removing autostart entry..."
    rm -f "$AUTOSTART_FILE"
fi

# Reset wallpaper if it was set to Nezuko background
plasma_wallpaper_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$plasma_wallpaper_config" ]; then
    if grep -q "background.png" "$plasma_wallpaper_config"; then
        echo "➡️ Resetting wallpaper configuration..."
        sed -i '/Image=.*background\.png/d' "$plasma_wallpaper_config"
    fi
fi

# Reset lockscreen wallpaper if it was set to Nezuko background
KSCREENLOCKER_CONF="$HOME/.config/kscreenlockerrc"
if [ -f "$KSCREENLOCKER_CONF" ]; then
    if grep -q "background.png" "$KSCREENLOCKER_CONF"; then
        echo "➡️ Resetting lockscreen wallpaper configuration..."
        sed -i '/Wallpaper=.*background\.png/d' "$KSCREENLOCKER_CONF"
    fi
fi

echo "✅ Uninstallation complete!"
echo "ℹ️  You may need to manually select a different theme in System Settings > Appearance"
echo "ℹ️  You may need to restart plasmashell: kquitapp plasmashell && plasmashell &"