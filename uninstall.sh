#!/bin/bash

set -euo pipefail

echo "🗑️  Uninstalling Nezuko KDE theme..."
echo ""

# ⚠️  CUSTOM XDG_CONFIG_HOME SETUP
# If you used a custom config directory during installation, set it here:
# export XDG_CONFIG_HOME=$HOME/.config-arch
# ./uninstall.sh
echo "Current XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set (will use ~/.config)}"
echo ""

# KDE user dirs
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"
COLOR_DIR="$HOME/.local/share/color-schemes"
KONSOLE_DIR="$HOME/.local/share/konsole"
LOCAL_BIN="$HOME/.local/bin"
AUTOSTART_DIR="$CONFIG_HOME/autostart"

# Theme names
CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko.desktop"  # Updated to match install.sh
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

# Function: reset konsole profiles
reset_konsole_profiles() {
    if compgen -G "$KONSOLE_DIR/*.profile" > /dev/null; then
        echo "➡️ Resetting Konsole profiles to default color scheme..."
        for profile in "$KONSOLE_DIR"/*.profile; do
            if grep -q "^ColorScheme=NezukoKamado" "$profile"; then
                echo "Resetting $profile to Breeze color scheme"
                sed -i 's/^ColorScheme=NezukoKamado/ColorScheme=Breeze/g' "$profile"
            fi
        done

        # Reset default profile in konsolerc
        KONSOLE_CONFIG="$CONFIG_HOME/konsolerc"
        if [ -f "$KONSOLE_CONFIG" ]; then
            if grep -q "^DefaultProfile=" "$KONSOLE_CONFIG"; then
                echo "Resetting default Konsole profile..."
                sed -i 's/^DefaultProfile=.*/DefaultProfile=/g' "$KONSOLE_CONFIG"
            fi
        fi
    fi
}

# Function: reset wallpaper configurations
reset_wallpaper_configs() {
    # Reset Plasma wallpaper
    PLASMA_CONFIG="$CONFIG_HOME/plasma-org.kde.plasma.desktop-appletsrc"
    if [ -f "$PLASMA_CONFIG" ]; then
        if grep -q "background.png" "$PLASMA_CONFIG"; then
            echo "➡️ Resetting Plasma wallpaper configuration..."
            # Reset to default wallpaper
            sed -i 's|Image=.*background\.png|Image=|g' "$PLASMA_CONFIG"
            # Alternative approach for different config formats
            sed -i '/background\.png/d' "$PLASMA_CONFIG"
        fi
    fi

    # Reset lockscreen wallpaper
    KSCREENLOCKER_CONF="$CONFIG_HOME/kscreenlockerrc"
    if [ -f "$KSCREENLOCKER_CONF" ]; then
        if grep -q "background.png" "$KSCREENLOCKER_CONF"; then
            echo "➡️ Resetting lockscreen wallpaper configuration..."
            sed -i '/Wallpaper=.*background\.png/d' "$KSCREENLOCKER_CONF"
            # Reset to default if empty
            if ! grep -q "^Wallpaper=" "$KSCREENLOCKER_CONF"; then
                sed -i '/^\[Greeter\]/a Wallpaper=' "$KSCREENLOCKER_CONF"
            fi
        fi
    fi
}

# Function: remove splash components
remove_splash_components() {
    # Remove standalone splash binary
    SPLASH_BIN="$LOCAL_BIN/nezuko-splash"
    if [ -f "$SPLASH_BIN" ]; then
        echo "➡️ Removing standalone splash executable..."
        rm -f "$SPLASH_BIN"
    fi

    # Remove splash resources
    SPLASH_RESOURCES="$LOCAL_BIN/nezuko-splash-resources"
    if [ -d "$SPLASH_RESOURCES" ]; then
        echo "➡️ Removing splash resources..."
        rm -rf "$SPLASH_RESOURCES"
    fi

    # Remove autostart entry
    AUTOSTART_FILE="$AUTOSTART_DIR/nezuko-splash.desktop"
    if [ -f "$AUTOSTART_FILE" ]; then
        echo "➡️ Removing autostart entry..."
        rm -f "$AUTOSTART_FILE"
    fi
}

# Function: check if theme is currently active
check_active_theme() {
    echo "🔍 Checking if Nezuko theme is currently active..."
    echo ""

    # Check plasma style (try KDE6 first, then fallback to KDE5)
    if command -v kreadconfig6 >/dev/null 2>&1; then
        CURRENT_PLASMA=$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || echo "")
        if [ "$CURRENT_PLASMA" = "$PLASMA_NAME" ]; then
            echo "⚠️  WARNING: Nezuko plasma style is currently active!"
            echo "   Please change to another theme in System Settings > Appearance"
        fi
    elif command -v kreadconfig5 >/dev/null 2>&1; then
        CURRENT_PLASMA=$(kreadconfig5 --file plasmarc --group Theme --key name 2>/dev/null || echo "")
        if [ "$CURRENT_PLASMA" = "$PLASMA_NAME" ]; then
            echo "⚠️  WARNING: Nezuko plasma style is currently active!"
            echo "   Please change to another theme in System Settings > Appearance"
        fi
    fi

    # Check icons (try KDE6 first, then fallback to KDE5)
    if command -v kreadconfig6 >/dev/null 2>&1; then
        CURRENT_ICONS=$(kreadconfig6 --file kdeglobals --group Icons --key Theme 2>/dev/null || echo "")
        if [ "$CURRENT_ICONS" = "$ICON_NAME" ]; then
            echo "⚠️  WARNING: Nezuko icons are currently active!"
            echo "   Please change to another icon theme in System Settings > Appearance"
        fi
    elif command -v kreadconfig5 >/dev/null 2>&1; then
        CURRENT_ICONS=$(kreadconfig5 --file kdeglobals --group Icons --key Theme 2>/dev/null || echo "")
        if [ "$CURRENT_ICONS" = "$ICON_NAME" ]; then
            echo "⚠️  WARNING: Nezuko icons are currently active!"
            echo "   Please change to another icon theme in System Settings > Appearance"
        fi
    fi

    # Check cursors
    if [ -f "$HOME/.icons/default/index.theme" ]; then
        if grep -q "Inherits=$CURSOR_NAME" "$HOME/.icons/default/index.theme"; then
            echo "⚠️  WARNING: Nezuko cursors are currently active!"
            echo "   Please change to another cursor theme in System Settings > Appearance"
        fi
    fi
    echo ""
}

# Function: refresh system caches
refresh_system_caches() {
    echo "➡️ Refreshing system caches..."
    if command -v kbuildsycoca6 >/dev/null 2>&1; then
        kbuildsycoca6
    fi

    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5
    fi
    echo "✅ System caches refreshed"
}

# -------------------------
# Main uninstallation process
# -------------------------

echo "📋 Starting Nezuko theme uninstallation..."

# Remove theme components
remove_theme_component "$CURSOR_DIR/$CURSOR_NAME" "cursors"
remove_theme_component "$ICON_DIR/$ICON_NAME" "icons"
remove_theme_component "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
remove_system_theme_component "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"
remove_theme_component "$COLOR_DIR/$COLOR_NAME" "color scheme"
remove_theme_component "$KONSOLE_DIR/$KONSOLE_NAME" "Konsole color scheme"

# Remove any leftover Nezuko files in color schemes
echo "➡️ Cleaning up any leftover color scheme files..."
find "$COLOR_DIR" -name "*Nezuko*" -exec echo "Removing: {}" \; -exec rm -f {} \;

# Remove any leftover Nezuko files in konsole schemes
echo "➡️ Cleaning up any leftover Konsole color schemes..."
find "$KONSOLE_DIR" -name "*Nezuko*" -exec echo "Removing: {}" \; -exec rm -f {} \;

# Reset Konsole profiles
reset_konsole_profiles

# Remove splash components
remove_splash_components

# Reset wallpaper configurations
reset_wallpaper_configs

# Refresh system caches
refresh_system_caches

# Check if theme was active
check_active_theme

echo ""
echo "✅ Uninstallation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. If Nezuko theme was active, please change to another theme in:"
echo "      System Settings > Appearance"
echo "   2. You may need to restart plasmashell for changes to take effect:"
echo "      kquitapp plasmashell && plasmashell &"
echo "   3. Log out and log back in for complete cleanup"
echo ""
echo "💝 Thank you for trying Nezuko Theme!"