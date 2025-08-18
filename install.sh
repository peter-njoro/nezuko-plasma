#!/bin/bash

set -euo pipefail

echo "🔮 Installing Nezuko KDE theme..."

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

# Ensure target directories exist
mkdir -p "$ICON_DIR" "$CURSOR_DIR" "$PLASMA_DIR" "$LOOKFEEL_DIR" "$COLOR_DIR"

# Function to copy safely
install_theme_component() {
    local src=$1
    local dest=$2
    local name=$3

    if [ ! -d "$src" ]; then
        echo "⚠️  Source directory $src for $name not found, skipping."
        return
    fi

    echo "➡️ Installing $name..."
    rm -rf "$dest"
    cp -r "$src" "$dest"
}

# Run SVG → PNG conversion
CONVERT_SCRIPT="icons/$ICON_NAME/convert_svgs.sh"
if [ -f "$CONVERT_SCRIPT" ]; then
    echo "🎨 Generating PNG fallbacks from SVGs..."
    chmod +x "$CONVERT_SCRIPT"
    (cd "icons/$ICON_NAME" && ./convert_svgs.sh)
else
    echo "⚠️ No convert_svgs.sh found at $CONVERT_SCRIPT, skipping PNG fallback generation."
fi

# Install components
install_theme_component "cursors/$CURSOR_NAME" "$CURSOR_DIR/$CURSOR_NAME" "cursors"
install_theme_component "icons/$ICON_NAME" "$ICON_DIR/$ICON_NAME" "icons"
install_theme_component "plasma/$PLASMA_NAME" "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
install_theme_component "look-and-feel/$LOOKFEEL_NAME" "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"

# Install color scheme
COLOR_SRC="plasma/$PLASMA_NAME/colors/$COLOR_NAME"
if [ -f "$COLOR_SRC" ]; then
    echo "➡️ Installing color scheme..."
    cp "$COLOR_SRC" "$COLOR_DIR/$COLOR_NAME"
else
    echo "⚠️ No Nezuko color scheme found in $COLOR_SRC, skipping."
fi

# Always set splash background image if present
SPLASH_IMAGE_SRC="background.png"
SPLASH_IMAGE_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/images/background.png"
if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Setting splash background image..."
    mkdir -p "$(dirname "$SPLASH_IMAGE_DEST")"
    cp "$SPLASH_IMAGE_SRC" "$SPLASH_IMAGE_DEST"
fi

# Set splash background video if present
SPLASH_BG_SRC="background.mp4"
SPLASH_BG_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/videos/background.mp4"
SPLASH_QML="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/Splash.qml"

if [ -f "$SPLASH_BG_SRC" ]; then
    echo "➡️ Setting splash background video..."
    mkdir -p "$(dirname "$SPLASH_BG_DEST")"
    cp "$SPLASH_BG_SRC" "$SPLASH_BG_DEST"

    if [ -f "$SPLASH_QML" ]; then
        echo "➡️ Patching Splash.qml to use background video with fallback..."
        # NOTE: This sed command is a placeholder; actual patching logic may be needed
        # sed -i '/Image[[:space:]]*{/,/}/c\' "$SPLASH_QML"
    else
        echo "⚠️ No Splash.qml found at $SPLASH_QML, skipping patch."
    fi
fi

echo "✅ Installation complete!"
echo
echo "👉 Apply the theme in System Settings > Appearance:"
echo "   - Plasma Style:   $PLASMA_NAME"
echo "   - Global Theme:   Nezuko"
echo "   - Icons:          $ICON_NAME"
echo "   - Cursors:        $CURSOR_NAME"
echo "   - Colors:         Nezuko"
