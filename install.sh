#!/bin/bash

set -euo pipefail

echo "🔮 Installing Nezuko KDE theme..."

# -------------------------
# Directories & theme names
# -------------------------
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
COLOR_DIR="$HOME/.local/share/color-schemes"
LOCAL_BIN="$HOME/.local/bin"

CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko"
COLOR_NAME="Nezuko.colors"

ICON_PACK_DIR="icons/$ICON_NAME/scalable"
BREEZE_ICON_SRC="/usr/share/icons/breeze/scalable"  # Default Breeze icon location

mkdir -p "$ICON_DIR" "$CURSOR_DIR" "$PLASMA_DIR" "$LOOKFEEL_DIR" "$COLOR_DIR" "$LOCAL_BIN" "$ICON_PACK_DIR"

# -------------------------
# Helper functions
# -------------------------
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
    sudo chown -R "$(whoami)":"$(whoami)" "$dest"
}

recolor_svg() {
    local svg=$1
    local dest=$2

    # Use Inkscape if available
    if command -v inkscape >/dev/null 2>&1; then
        inkscape "$svg" --export-filename="$dest" --actions="select-all;object-set-fill:#ff66aa;export-do"
    elif command -v xmlstarlet >/dev/null 2>&1; then
        cp "$svg" "$dest"
        xmlstarlet ed -L -u "//*[local-name()='path']/@fill" -v "#ff66aa" "$dest"
    else
        echo "⚠️  Neither Inkscape nor xmlstarlet found; copying without recolor"
        cp "$svg" "$dest"
    fi
}

# -------------------------
# Recolor Breeze icons and add to Nezuko pack
# -------------------------
if [ -d "$BREEZE_ICON_SRC" ]; then
    echo "🎨 Copying and recoloring Breeze icons to pink..."
    mkdir -p "$ICON_PACK_DIR"
    
    # Copy and recolor Breeze SVGs
    find "$BREEZE_ICON_SRC" -name "*.svg" | while read -r breeze_svg; do
        filename=$(basename "$breeze_svg")
        dest_svg="$ICON_PACK_DIR/$filename"
        
        # Skip if already exists (Nezuko pack takes priority)
        if [ ! -f "$dest_svg" ]; then
            recolor_svg "$breeze_svg" "$dest_svg"
        fi
    done
    echo "✅ Breeze icons recolored and merged into Nezuko pack"
else
    echo "⚠️  Breeze icons not found at $BREEZE_ICON_SRC, skipping."
fi

# -------------------------
# Recolor existing Nezuko icons (if any)
# -------------------------
if [ -d "$ICON_PACK_DIR" ]; then
    echo "🎨 Recoloring existing Nezuko icons to pink..."
    for svg in "$ICON_PACK_DIR"/*.svg; do
        [ -e "$svg" ] || continue
        recolor_svg "$svg" "$svg"
    done
    echo "✅ Nezuko icons recolored to pink"
else
    echo "⚠️  Nezuko icon directory $ICON_PACK_DIR not found, skipping recolor."
fi

# -------------------------
# Run PNG fallback conversion
# -------------------------
CONVERT_SCRIPT="icons/$ICON_NAME/convert_svgs.sh"
if [ -f "$CONVERT_SCRIPT" ]; then
    echo "🎨 Generating PNG fallbacks from SVGs..."
    chmod +x "$CONVERT_SCRIPT"
    (cd "icons/$ICON_NAME" && ./convert_svgs.sh)
else
    echo "⚠️ No convert_svgs.sh found at $CONVERT_SCRIPT, skipping PNG fallback generation."
fi

# -------------------------
# Install theme components
# -------------------------
install_theme_component "cursors/$CURSOR_NAME" "$CURSOR_DIR/$CURSOR_NAME" "cursors"
install_theme_component "icons/$ICON_NAME" "$ICON_DIR/$ICON_NAME" "icons"
install_theme_component "plasma/$PLASMA_NAME" "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
install_theme_component "look-and-feel/$LOOKFEEL_NAME" "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"

# Color scheme
COLOR_SRC="plasma/$PLASMA_NAME/colors/$COLOR_NAME"
if [ -f "$COLOR_SRC" ]; then
    echo "➡️ Installing color scheme..."
    cp "$COLOR_SRC" "$COLOR_DIR/$COLOR_NAME"
    sudo chown "$(whoami)":"$(whoami)" "$COLOR_DIR/$COLOR_NAME"
else
    echo "⚠️ No Nezuko color scheme found in $COLOR_SRC, skipping."
fi

# -------------------------
# Splash resources
# -------------------------
SPLASH_IMAGE_SRC="background.png"
SPLASH_IMAGE_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/images/background.png"
SPLASH_VIDEO_SRC="background.mp4"
SPLASH_VIDEO_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/videos/background.mp4"

if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Copying splash image..."
    mkdir -p "$(dirname "$SPLASH_IMAGE_DEST")"
    cp "$SPLASH_IMAGE_SRC" "$SPLASH_IMAGE_DEST"
    sudo chown "$(whoami)":"$(whoami)" "$SPLASH_IMAGE_DEST"
fi

if [ -f "$SPLASH_VIDEO_SRC" ]; then
    echo "➡️ Copying splash video..."
    mkdir -p "$(dirname "$SPLASH_VIDEO_DEST")"
    cp "$SPLASH_VIDEO_SRC" "$SPLASH_VIDEO_DEST"
    sudo chown "$(whoami)":"$(whoami)" "$SPLASH_VIDEO_DEST"
fi

# -------------------------
# Build standalone splash
# -------------------------
SPLASH_SRC_DIR="nezuko-splash"
SPLASH_BUILD_DIR="$SPLASH_SRC_DIR/build"
SPLASH_EXEC="$LOCAL_BIN/nezuko-splash"

if [ -d "$SPLASH_SRC_DIR" ]; then
    echo "➡️ Building standalone animated splash app..."
    mkdir -p "$SPLASH_BUILD_DIR"
    cd "$SPLASH_BUILD_DIR"
    
    qmake ../nezuko-splash.pro
    make -j$(nproc)
    
    if [ -f "nezuko-splash" ]; then
        cp nezuko-splash "$SPLASH_EXEC"
        chmod +x "$SPLASH_EXEC"
        sudo chown "$(whoami)":"$(whoami)" "$SPLASH_EXEC"
        echo "✅ Standalone splash installed at $SPLASH_EXEC"
    else
        echo "⚠️ Failed to build standalone splash executable."
    fi

    cd ../../
else
    echo "⚠️ Splash source directory $SPLASH_SRC_DIR not found, skipping build."
fi

# -------------------------
# Auto-start at login
# -------------------------
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/nezuko-splash.desktop"

mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_FILE" <<EOL
[Desktop Entry]
Type=Application
Exec=$SPLASH_EXEC
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Nezuko Splash
Comment=Cinematic animated KDE splash
EOL

# -------------------------
# Completion message
# -------------------------
echo "✅ Installation complete!"
echo "👉 Apply the theme in System Settings > Appearance:"
echo "   - Plasma Style:   $PLASMA_NAME"
echo "   - Global Theme:   Nezuko"
echo "   - Icons:          $ICON_NAME"
echo "   - Cursors:        $CURSOR_NAME"
echo "   - Colors:         Nezuko"
echo "➡️ Your standalone animated splash will run at login."