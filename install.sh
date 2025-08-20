#!/bin/bash

set -euo pipefail

echo "🔮 Installing Nezuko KDE theme..."

# -------------------------
# Directories & theme names
# -------------------------
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"  # Changed to system-wide
COLOR_DIR="$HOME/.local/share/color-schemes"
KONSOLE_DIR="$HOME/.local/share/konsole"
LOCAL_BIN="$HOME/.local/bin"

CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko"
COLOR_NAME="Nezuko.colors"
KONSOLE_NAME="NezukoKamado.colorscheme"

BREEZE_ICON_SRC="/usr/share/icons/breeze/scalable"

# Create all necessary directories
mkdir -p "$ICON_DIR" "$CURSOR_DIR" "$PLASMA_DIR" "$COLOR_DIR" "$LOCAL_BIN"

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

install_system_theme_component() {
    local src=$1
    local dest=$2
    local name=$3

    if [ ! -d "$src" ]; then
        echo "⚠️  Source directory $src for $name not found, skipping."
        return
    fi

    echo "➡️ Installing $name (system-wide)..."
    sudo rm -rf "$dest"
    sudo cp -r "$src" "$dest"
    sudo chown -R root:root "$dest"
}

recolor_svg() {
    local svg=$1
    local dest=$2

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
# Prepare Nezuko icon pack
# -------------------------
# First copy the original Nezuko icons to the destination
NEZUKO_ICON_SRC="icons/$ICON_NAME"
NEZUKO_ICON_DEST="$ICON_DIR/$ICON_NAME"

if [ -d "$NEZUKO_ICON_SRC" ]; then
    echo "➡️ Copying base Nezuko icons..."
    rm -rf "$NEZUKO_ICON_DEST"
    cp -r "$NEZUKO_ICON_SRC" "$NEZUKO_ICON_DEST"
else
    echo "⚠️  Base Nezuko icons not found at $NEZUKO_ICON_SRC, skipping."
fi

# -------------------------
# Recolor Breeze icons into Nezuko pack
# -------------------------
if [ -d "$BREEZE_ICON_SRC" ] && [ -d "$NEZUKO_ICON_DEST" ]; then
    echo "🎨 Copying and recoloring Breeze icons to pink (as $ICON_NAME)..."
    mkdir -p "$NEZUKO_ICON_DEST/scalable"

    # Process each SVG
    find "$BREEZE_ICON_SRC" -name "*.svg" | while read -r breeze_svg; do
        filename=$(basename "$breeze_svg")
        dest_svg="$NEZUKO_ICON_DEST/scalable/$filename"

        # Only process if not already in Nezuko pack
        if [ ! -f "$dest_svg" ]; then
            recolor_svg "$breeze_svg" "$dest_svg"
            # Ensure the icon gets Nezuko's color scheme
            sed -i 's/fill:#[0-9a-fA-F]*/fill:#ff66aa/g' "$dest_svg"
        fi
    done
    echo "✅ Breeze icons recolored and added to $ICON_NAME pack"
else
    echo "⚠️  Breeze icons not found at $BREEZE_ICON_SRC or Nezuko icon destination not ready, skipping."
fi

# -------------------------
# Recolor existing Nezuko icons
# -------------------------
if [ -d "$NEZUKO_ICON_DEST/scalable" ]; then
    echo "🎨 Ensuring all $ICON_NAME icons are pink..."
    for svg in "$NEZUKO_ICON_DEST/scalable"/*.svg; do
        [ -e "$svg" ] || continue
        # Force recolor to ensure consistency
        sed -i 's/fill:#[0-9a-fA-F]*/fill:#ff66aa/g' "$svg"
    done
    echo "✅ $ICON_NAME icons verified to be pink"
else
    echo "⚠️  $ICON_NAME icon directory $NEZUKO_ICON_DEST/scalable not found, skipping recolor."
fi

# -------------------------
# Run PNG fallback conversion
# -------------------------
CONVERT_SCRIPT="$NEZUKO_ICON_DEST/convert_svgs.sh"
if [ -f "$CONVERT_SCRIPT" ]; then
    echo "🎨 Generating PNG fallbacks from SVGs..."
    chmod +x "$CONVERT_SCRIPT"
    (cd "$NEZUKO_ICON_DEST" && ./convert_svgs.sh)
else
    echo "⚠️ No convert_svgs.sh found at $CONVERT_SCRIPT, skipping PNG fallback generation."
fi

# -------------------------
# Install theme components
# -------------------------
install_theme_component "cursors/$CURSOR_NAME" "$CURSOR_DIR/$CURSOR_NAME" "cursors"
# Icons are already installed above, no need to install again
install_theme_component "plasma/$PLASMA_NAME" "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
install_system_theme_component "look-and-feel/$LOOKFEEL_NAME" "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"  # Changed to system-wide
install_theme_component "konsole/$KONSOLE_NAME" "$KONSOLE_DIR/$KONSOLE_NAME" "Konsole color scheme"

# -------------------------
# Color scheme
# -------------------------
COLOR_SRC="plasma/$PLASMA_NAME/colors/$COLOR_NAME"
if [ -f "$COLOR_SRC" ]; then
    echo "➡️ Installing color scheme..."
    cp "$COLOR_SRC" "$COLOR_DIR/$COLOR_NAME"
    sudo chown "$(whoami)":"$(whoami)" "$COLOR_DIR/$COLOR_NAME"
else
    echo "⚠️ No Nezuko color scheme found in $COLOR_SRC, skipping."
fi

KONSOLE_SRC="konsole/$KONSOLE_NAME"
if [ -f "$KONSOLE_SRC" ]; then
    echo "➡️ Installing Konsole color scheme..."
    cp "$KONSOLE_SRC" "$KONSOLE_DIR/$KONSOLE_NAME"
    sudo chown "$(whoami)":"$(whoami)" "$KONSOLE_DIR/$KONSOLE_NAME"
else
    echo "⚠️ No Nezuko Konsole color scheme found in $KONSOLE_SRC, skipping."
fi

# -------------------------
# Splash resources
# -------------------------
SPLASH_IMAGE_SRC="background.png"
SPLASH_IMAGE_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/images/background.png"
SPLASH_VIDEO_SRC="background.mp4"
SPLASH_VIDEO_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/videos/background.mp4"

if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Copying splash image (system-wide)..."
    sudo mkdir -p "$(dirname "$SPLASH_IMAGE_DEST")"
    sudo cp "$SPLASH_IMAGE_SRC" "$SPLASH_IMAGE_DEST"
    sudo chown root:root "$SPLASH_IMAGE_DEST"
fi

if [ -f "$SPLASH_VIDEO_SRC" ]; then
    echo "➡️ Copying splash video (system-wide)..."
    sudo mkdir -p "$(dirname "$SPLASH_VIDEO_DEST")"
    sudo cp "$SPLASH_VIDEO_SRC" "$SPLASH_VIDEO_DEST"
    sudo chown root:root "$SPLASH_VIDEO_DEST"
fi

plasma_wallpaper_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$SPLASH_IMAGE_SRC" ] && [ -f "$plasma_wallpaper_config" ]; then
    echo "➡️ Setting background.png as Plasma wallpaper (current user)..."
    sed -i "s|^Image=.*|Image=file://$PWD/$SPLASH_IMAGE_SRC|" "$plasma_wallpaper_config"
fi

# -------------------------
# Build standalone splash
# -------------------------
SPLASH_SRC_DIR="nezuko-splash"
SPLASH_BUILD_DIR="$SPLASH_SRC_DIR/build"
SPLASH_EXEC="$LOCAL_BIN/nezuko-splash"
SPLASH_EXEC_DIR="$LOCAL_BIN/nezuko-splash-resources"

if [ -d "$SPLASH_SRC_DIR" ]; then
    echo "➡️ Building standalone animated splash app (this may take a while, please be patient 🥺🥺)..."
    mkdir -p "$SPLASH_BUILD_DIR"
    cd "$SPLASH_BUILD_DIR"

    qmake ../nezuko-splash.pro
    make -j$(nproc)

    if [ -f "nezuko-splash" ]; then
        # Copy the executable
        cp nezuko-splash "$SPLASH_EXEC"
        chmod +x "$SPLASH_EXEC"
        sudo chown "$(whoami)":"$(whoami)" "$SPLASH_EXEC"

        # Copy splash resources
        mkdir -p "$SPLASH_EXEC_DIR"
        cp -r "$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash" "$SPLASH_EXEC_DIR"
        sudo chown -R "$(whoami)":"$(whoami)" "$SPLASH_EXEC_DIR"

        echo "✅ Standalone splash installed at $SPLASH_EXEC"
        echo "✅ Splash resources copied to $SPLASH_EXEC_DIR"
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
# Set Konsole color scheme as default for all profiles
# -------------------------
if compgen -G "$KONSOLE_DIR/*.profile" > /dev/null; then
    echo "➡️ Setting NezukoKamado as the default Konsole color scheme for all profiles..."
    for profile in "$KONSOLE_DIR"/*.profile; do
        # Check if ColorScheme line exists
        if grep -q "^ColorScheme=" "$profile"; then
            sed -i 's/^ColorScheme=.*/ColorScheme=NezukoKamado/' "$profile"
        else
            echo "ColorScheme=NezukoKamado" >> "$profile"
        fi
    done

    # Also set as default in the main konsole configuration
    KONSOLE_CONFIG="$HOME/.config/konsolerc"
    if [ -f "$KONSOLE_CONFIG" ]; then
        if grep -q "^DefaultProfile=" "$KONSOLE_CONFIG"; then
            # Find the first profile and set it to use our color scheme
            first_profile=$(ls "$KONSOLE_DIR"/*.profile 2>/dev/null | head -n1)
            if [ -n "$first_profile" ]; then
                profile_name=$(basename "$first_profile" .profile)
                sed -i "s/^DefaultProfile=.*/DefaultProfile=$profile_name/" "$KONSOLE_CONFIG"
            fi
        fi
    fi
fi

# -------------------------
# Set lockscreen wallpaper (Plasma, may not work on all versions)
# -------------------------
KSCREENLOCKER_CONF="$HOME/.config/kscreenlockerrc"
if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Attempting to set lockscreen wallpaper to background.png..."
    # Add or update the Wallpaper entry under [Greeter]
    if grep -q "^\[Greeter\]" "$KSCREENLOCKER_CONF" 2>/dev/null; then
        # Section exists, update or add Wallpaper line
        if grep -q "^Wallpaper=" "$KSCREENLOCKER_CONF"; then
            sed -i "s|^Wallpaper=.*|Wallpaper=file://$PWD/$SPLASH_IMAGE_SRC|" "$KSCREENLOCKER_CONF"
        else
            sed -i "/^\[Greeter\]/a Wallpaper=file://$PWD/$SPLASH_IMAGE_SRC" "$KSCREENLOCKER_CONF"
        fi
    else
        # Section doesn't exist, append it
        echo -e "[Greeter]\nWallpaper=file://$PWD/$SPLASH_IMAGE_SRC" >> "$KSCREENLOCKER_CONF"
    fi
fi

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
echo "➡️ Konsole color scheme has been set as default for all profiles."
