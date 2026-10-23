#!/usr/bin/env bash
# install_from_archives.sh
# Install the Nezuko theme pack from the pre-built KDE Store archives in pack/.
#
# Usage: ./install_from_archives.sh [--system]
#   --system  install global theme + color scheme system-wide (needs sudo)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$SCRIPT_DIR/pack"
SYSTEM="${1:-}"

if [ ! -d "$PACK_DIR" ]; then
    echo "❌ pack/ not found. Run pack_kde_store.py --all first."
    exit 1
fi

# Install destinations (override via env vars for testing)
ICON_DIR="${ICON_DIR:-$HOME/.local/share/icons}"
PLASMA_DIR="${PLASMA_DIR:-$HOME/.local/share/plasma/desktoptheme}"
COLOR_DIR="${COLOR_DIR:-$HOME/.local/share/color-schemes}"
LNF_DIR="${LNF_DIR:-$HOME/.local/share/plasma/look-and-feel}"

if [ "$SYSTEM" = "--system" ]; then
    ICON_DIR="/usr/share/icons"
    PLASMA_DIR="/usr/share/plasma/desktoptheme"
    COLOR_DIR="/usr/share/color-schemes"
    LNF_DIR="/usr/share/plasma/look-and-feel"
fi

run() {
    if [ "$SYSTEM" = "--system" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

echo "📦 Installing Nezuko theme pack from archives..."

install_zip() {
    local zip="$1" dest_dir="$2" name="$3"
    local tmp
    tmp="$(mktemp -d)"
    run unzip -qo "$zip" -d "$tmp"
    local top
    top="$(ls "$tmp")"
    echo "➡️ Installing $name → $dest_dir/$top"
    run mkdir -p "$dest_dir"
    run rm -rf "$dest_dir/$top"
    run mv "$tmp/$top" "$dest_dir/$top"
    run chown -R "${SUDO_USER:-$(whoami)}": "${dest_dir/$top}" 2>/dev/null || true
    rm -rf "$tmp"
}

echo "📦 Installing Nezuko theme pack from archives..."

install_zip "$PACK_DIR/plasma-desktoptheme-Nezuko.zip" "$PLASMA_DIR" "plasma style (dark)"
install_zip "$PACK_DIR/plasma-desktoptheme-Nezuko-Light.zip" "$PLASMA_DIR" "plasma style (light)"
install_zip "$PACK_DIR/icontheme-Nezuko-Icons.zip" "$ICON_DIR" "icon theme"
install_zip "$PACK_DIR/cursortheme-Nezuko-Cursors.zip" "$ICON_DIR" "cursor theme"
install_zip "$PACK_DIR/lookandfeel-org.kde.nezuko.desktop.zip" "$LNF_DIR" "global theme"

# Color schemes: single-file archives
for z in "$PACK_DIR"/colorscheme-*.zip; do
    [ -e "$z" ] || continue
    name="$(basename "$z" .zip)"
    run mkdir -p "$COLOR_DIR"
    run sh -c "unzip -p '$z' '$name/$name.colors' > '$COLOR_DIR/$name.colors'" 2>/dev/null || true
    echo "➡️ Installed color scheme $name.colors"
done

echo "✅ Nezuko theme pack installed."
echo "   Switch in System Settings → Colors & Themes"

echo "✅ Nezuko theme pack installed."
echo "   Switch in System Settings → Colors & Themes"