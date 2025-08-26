#!/bin/bash

set -euo pipefail

echo "🔮 Installing Nezuko KDE theme..."

# -------------------------
# Directories & theme names
# -------------------------
ICON_DIR="$HOME/.local/share/icons"
CURSOR_DIR="$HOME/.local/share/icons"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"
COLOR_DIR="$HOME/.local/share/color-schemes"
KONSOLE_DIR="$HOME/.local/share/konsole"
LOCAL_BIN="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"

CURSOR_NAME="Nezuko-Cursors"
ICON_NAME="Nezuko-Icons"
PLASMA_NAME="Nezuko"
LOOKFEEL_NAME="org.kde.nezuko.desktop"
COLOR_NAME="Nezuko.colors"
KONSOLE_NAME="NezukoKamado.colorscheme"

BREEZE_ICON_SRC="/usr/share/icons/breeze/scalable"

# Create all necessary directories
mkdir -p "$ICON_DIR" "$CURSOR_DIR" "$PLASMA_DIR" "$COLOR_DIR" "$LOCAL_BIN" "$AUTOSTART_DIR"

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
    chown -R "$(whoami)":"$(whoami)" "$dest"
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

    find "$BREEZE_ICON_SRC" -name "*.svg" | while read -r breeze_svg; do
        filename=$(basename "$breeze_svg")
        dest_svg="$NEZUKO_ICON_DEST/scalable/$filename"

        if [ ! -f "$dest_svg" ]; then
            recolor_svg "$breeze_svg" "$dest_svg"
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
# Create loading-spinner.svg for splash screen
# -------------------------
LOADING_SPINNER_SRC="look-and-feel/$LOOKFEEL_NAME/contents/splash/images/loading-spinner.svg"
LOADING_SPINNER_DEST_DIR="look-and-feel/$LOOKFEEL_NAME/contents/splash/images"
mkdir -p "$LOADING_SPINNER_DEST_DIR"

if [ ! -f "$LOADING_SPINNER_SRC" ]; then
    echo "➡️ Creating animated loading spinner SVG..."
    cat > "$LOADING_SPINNER_SRC" << 'EOL'
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
    <circle cx="32" cy="32" r="24" fill="none" stroke="#ff66aa" stroke-width="4" stroke-dasharray="37.7 37.7" stroke-dashoffset="0">
        <animateTransform attributeName="transform" type="rotate" from="0 32 32" to="360 32 32" dur="1.5s" repeatCount="indefinite"/>
    </circle>
</svg>
EOL
fi

# -------------------------
# Copy nezuko.svg to splash images
# -------------------------
NEZUKO_SVG_SRC="images/nezuko.svg"  # Update this path if your nezuko.svg is elsewhere
NEZUKO_SVG_DEST="look-and-feel/$LOOKFEEL_NAME/contents/splash/images/nezuko.svg"
if [ -f "$NEZUKO_SVG_SRC" ]; then
    echo "➡️ Copying nezuko.svg to splash images..."
    cp "$NEZUKO_SVG_SRC" "$NEZUKO_SVG_DEST"
else
    echo "⚠️ nezuko.svg not found at $NEZUKO_SVG_SRC, using default logo"
    # Create a simple placeholder if needed
    if [ ! -f "$NEZUKO_SVG_DEST" ]; then
        cat > "$NEZUKO_SVG_DEST" << 'EOL'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
    <circle cx="128" cy="128" r="100" fill="#ff66aa" opacity="0.8"/>
    <text x="128" y="140" text-anchor="middle" font-family="sans-serif" font-size="48" font-weight="bold" fill="white">N</text>
</svg>
EOL
    fi
fi

# -------------------------
# Create necessary directories and metadata for plasma theme
# -------------------------
mkdir -p "plasma/$PLASMA_NAME/widgets/shadows"
mkdir -p "plasma/$PLASMA_NAME/shadows"
mkdir -p "plasma/$PLASMA_NAME/translucent/dialogs"
mkdir -p "plasma/$PLASMA_NAME/opaque/dialogs"

if [ ! -f "plasma/$PLASMA_NAME/metadata.desktop" ]; then
    echo "➡️ Creating plasma theme metadata..."
    cat > "plasma/$PLASMA_NAME/metadata.desktop" << 'EOL'
[Desktop Entry]
Name=Nezuko
Comment=Nezuko-inspired KDE Plasma theme with glassy dialogs, rounded corners, and shadows
X-KDE-PluginInfo-Author=Peter Chege
X-KDE-PluginInfo-Email=peterchegen12@gmail.com
X-KDE-PluginInfo-Name=Nezuko
X-KDE-PluginInfo-Version=1.2
X-KDE-PluginInfo-Website=https://github.com/peter-njoro/nezuko-plasma
X-KDE-PluginInfo-Category=Plasma Theme
X-KDE-PluginInfo-License=GPL
X-KDE-PluginInfo-EnabledByDefault=true
EOL
fi

# -------------------------
# Install theme components
# -------------------------
install_theme_component "cursors/$CURSOR_NAME" "$CURSOR_DIR/$CURSOR_NAME" "cursors"
install_theme_component "plasma/$PLASMA_NAME" "$PLASMA_DIR/$PLASMA_NAME" "plasma style"
install_system_theme_component "look-and-feel/$LOOKFEEL_NAME" "$LOOKFEEL_DIR/$LOOKFEEL_NAME" "global theme"
install_theme_component "konsole/$KONSOLE_NAME" "$KONSOLE_DIR/$KONSOLE_NAME" "Konsole color scheme"

# -------------------------
# Color scheme
# -------------------------
COLOR_SRC="plasma/$PLASMA_NAME/colors/$COLOR_NAME"
if [ -f "$COLOR_SRC" ]; then
    echo "➡️ Installing color scheme..."
    cp "$COLOR_SRC" "$COLOR_DIR/$COLOR_NAME"
    chown "$(whoami)":"$(whoami)" "$COLOR_DIR/$COLOR_NAME"
else
    echo "⚠️ No Nezuko color scheme found in $COLOR_SRC, skipping."
fi

# -------------------------
# Splash resources
# -------------------------
SPLASH_IMAGE_SRC="images/background.png"
SPLASH_IMAGE_DEST="$LOOKFEEL_DIR/$LOOKFEEL_NAME/contents/splash/images/background.png"

if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Copying splash image (system-wide)..."
    sudo mkdir -p "$(dirname "$SPLASH_IMAGE_DEST")"
    sudo cp "$SPLASH_IMAGE_SRC" "$SPLASH_IMAGE_DEST"
    sudo chown root:root "$SPLASH_IMAGE_DEST"
else
    echo "⚠️ Splash background image not found at $SPLASH_IMAGE_SRC"
fi

# -------------------------
# Build standalone splash
# -------------------------
SPLASH_SRC_DIR="nezuko-splash"
SPLASH_BUILD_DIR="$SPLASH_SRC_DIR/build"
SPLASH_EXEC="$LOCAL_BIN/nezuko-splash"
SPLASH_EXEC_DIR="$LOCAL_BIN/nezuko-splash-resources"

if [ -d "$SPLASH_SRC_DIR" ]; then
    echo "➡️ Building standalone animated splash app..."
    mkdir -p "$SPLASH_BUILD_DIR"
    cd "$SPLASH_SRC_DIR"

    if [ -f "CMakeLists.txt" ]; then
        mkdir -p build
        cd build
        cmake ..
        make -j$(nproc)
    elif [ -f "nezuko-splash.pro" ]; then
        mkdir -p build
        cd build
        qmake ..
        make -j$(nproc)
    else
        echo "⚠️ No build system found in splash directory, skipping build."
        cd ../..
        continue
    fi

    if [ -f "nezuko-splash" ]; then
        cp nezuko-splash "$SPLASH_EXEC"
        chmod +x "$SPLASH_EXEC"
        chown "$(whoami)":"$(whoami)" "$SPLASH_EXEC"

        mkdir -p "$SPLASH_EXEC_DIR"
        cp -r "../splash-resources/"* "$SPLASH_EXEC_DIR/" 2>/dev/null || true
        chown -R "$(whoami)":"$(whoami)" "$SPLASH_EXEC_DIR"

        echo "✅ Standalone splash installed at $SPLASH_EXEC"
    else
        echo "⚠️ Failed to build standalone splash executable."
    fi

    cd ../..
else
    echo "⚠️ Splash source directory $SPLASH_SRC_DIR not found, skipping build."
fi

# -------------------------
# Auto-start at login
# -------------------------
AUTOSTART_FILE="$AUTOSTART_DIR/nezuko-splash.desktop"

if [ -f "$SPLASH_EXEC" ]; then
    echo "➡️ Setting up auto-start for splash screen..."
    cat > "$AUTOSTART_FILE" << EOL
[Desktop Entry]
Type=Application
Exec=$SPLASH_EXEC
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Nezuko Splash
Comment=Cinematic animated KDE splash
EOL
    chmod +x "$AUTOSTART_FILE"
else
    echo "⚠️ Splash executable not found, skipping auto-start setup."
fi

# -------------------------
# Set Konsole color scheme as default for all profiles
# -------------------------
if compgen -G "$KONSOLE_DIR/*.profile" > /dev/null; then
    echo "➡️ Setting NezukoKamado as the default Konsole color scheme for all profiles..."
    for profile in "$KONSOLE_DIR"/*.profile; do
        if grep -q "^ColorScheme=" "$profile"; then
            sed -i 's/^ColorScheme=.*/ColorScheme=NezukoKamado/' "$profile"
        else
            echo "ColorScheme=NezukoKamado" >> "$profile"
        fi
    done

    KONSOLE_CONFIG="$HOME/.config/konsolerc"
    if [ -f "$KONSOLE_CONFIG" ]; then
        first_profile=$(ls "$KONSOLE_DIR"/*.profile 2>/dev/null | head -n1)
        if [ -n "$first_profile" ]; then
            profile_name=$(basename "$first_profile" .profile)
            sed -i "s/^DefaultProfile=.*/DefaultProfile=$profile_name/" "$KONSOLE_CONFIG"
        fi
    fi
fi

# -------------------------
# Set lockscreen wallpaper
# -------------------------
KSCREENLOCKER_CONF="$HOME/.config/kscreenlockerrc"
if [ -f "$SPLASH_IMAGE_SRC" ]; then
    echo "➡️ Setting lockscreen wallpaper..."
    if grep -q "^\[Greeter\]" "$KSCREENLOCKER_CONF" 2>/dev/null; then
        if grep -q "^Wallpaper=" "$KSCREENLOCKER_CONF"; then
            sed -i "s|^Wallpaper=.*|Wallpaper=file://$PWD/$SPLASH_IMAGE_SRC|" "$KSCREENLOCKER_CONF"
        else
            sed -i "/^\[Greeter\]/a Wallpaper=file://$PWD/$SPLASH_IMAGE_SRC" "$KSCREENLOCKER_CONF"
        fi
    else
        echo -e "[Greeter]\nWallpaper=file://$PWD/$SPLASH_IMAGE_SRC" >> "$KSCREENLOCKER_CONF"
    fi
fi

# -------------------------
# Set Plasma wallpaper
# -------------------------
PLASMA_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$SPLASH_IMAGE_SRC" ] && [ -f "$PLASMA_CONFIG" ]; then
    echo "➡️ Setting Plasma wallpaper..."
    if grep -q "^Image=" "$PLASMA_CONFIG"; then
        sed -i "s|^Image=.*|Image=file://$PWD/$SPLASH_IMAGE_SRC|" "$PLASMA_CONFIG"
    else
        # Find the first image entry and replace it
        sed -i "0,/^\[Containments\]\[[0-9]*\]\[General\]$/ { /^wallpaper=/s/.*/wallpaper=file:\/\/$PWD\/$SPLASH_IMAGE_SRC/ }" "$PLASMA_CONFIG"
    fi
fi

# -------------------------
# Refresh system caches
# -------------------------
echo "➡️ Refreshing system caches..."
if command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6
fi

# -------------------------
# Completion message
# -------------------------
echo ""
echo "🎉 ✅ Installation complete!"
echo ""
echo "👉 Apply the theme in System Settings > Appearance:"
echo "   - Plasma Style:   $PLASMA_NAME"
echo "   - Global Theme:   Nezuko"
echo "   - Icons:          $ICON_NAME"
echo "   - Cursors:        $CURSOR_NAME"
echo "   - Colors:         Nezuko"
echo ""
echo "➡️ Your standalone animated splash will run at login."
echo "➡️ Konsole color scheme has been set as default."
echo "➡️ Lockscreen wallpaper has been set."
echo ""
echo "🔄 You may need to log out and log back in for all changes to take effect."
echo ""
echo "💖 Thank you for using Nezuko Theme!"