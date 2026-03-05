#!/bin/bash

echo "🔍 Nezuko Theme Installation Diagnostics"
echo "========================================"
echo ""

# Check KDE version
echo "📊 KDE Version:"
if command -v plasmashell >/dev/null 2>&1; then
    plasmashell --version || echo "Could not detect"
fi
echo ""

# Check all installation directories
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
echo "📁 Checking installation directories..."
echo ""

check_dir() {
    local dir=$1
    local name=$2
    if [ -d "$dir" ]; then
        echo "✅ $name: $dir"
        ls -la "$dir" | head -10
        echo ""
    else
        echo "❌ $name: $dir (NOT FOUND)"
        echo ""
    fi
}

check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (NOT FOUND)"
    fi
}

# Plasma theme
echo "--- Plasma Theme ---"
check_dir "$HOME/.local/share/plasma/desktoptheme/Nezuko" "Plasma Theme"
check_file "$HOME/.local/share/plasma/desktoptheme/Nezuko/metadata.desktop" "Plasma metadata"

# Icons
echo "--- Icons ---"
check_dir "$HOME/.local/share/icons/Nezuko-Icons" "Icon Pack"
check_file "$HOME/.local/share/icons/Nezuko-Icons/index.theme" "Icon index.theme"

# Cursors
echo "--- Cursors ---"
check_dir "$HOME/.local/share/icons/Nezuko-Cursors" "Cursor Theme"
check_file "$HOME/.local/share/icons/Nezuko-Cursors/index.theme" "Cursor index.theme"

# Look and feel
echo "--- Look and Feel ---"
check_dir "/usr/share/plasma/look-and-feel/org.kde.nezuko.desktop" "Look and Feel"
check_file "/usr/share/plasma/look-and-feel/org.kde.nezuko.desktop/metadata.desktop" "L&F metadata"

# Color scheme
echo "--- Color Scheme ---"
check_file "$HOME/.local/share/color-schemes/Nezuko.colors" "Color scheme"

# Konsole
echo "--- Konsole Theme ---"
check_file "$HOME/.local/share/konsole/NezukoKamado.colorscheme" "Konsole colorscheme"

echo ""
echo "📋 Checking metadata validity..."
echo ""

check_metadata() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo "🔍 $name:"
        cat "$file" | head -15
        echo ""
    fi
}

check_metadata "$HOME/.local/share/plasma/desktoptheme/Nezuko/metadata.desktop" "Plasma metadata"
check_metadata "$HOME/.local/share/icons/Nezuko-Icons/index.theme" "Icon index.theme"
check_metadata "$HOME/.local/share/icons/Nezuko-Cursors/index.theme" "Cursor index.theme"
check_metadata "/usr/share/plasma/look-and-feel/org.kde.nezuko.desktop/metadata.desktop" "Look and Feel metadata"

echo ""
echo "🔐 Checking file permissions..."
echo ""

check_perms() {
    local path=$1
    local name=$2
    if [ -e "$path" ]; then
        echo "$name:"
        ls -ld "$path"
        echo ""
    fi
}

check_perms "$HOME/.local/share/icons/Nezuko-Icons" "Icon Pack"
check_perms "$HOME/.local/share/icons/Nezuko-Cursors" "Cursor Pack"
check_perms "$HOME/.local/share/plasma/desktoptheme/Nezuko" "Plasma Theme"
check_perms "/usr/share/plasma/look-and-feel/org.kde.nezuko.desktop" "Look and Feel"

echo ""
echo "🔄 Rebuilding KDE caches..."
echo ""

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    echo "Running kbuildsycoca6..."
    kbuildsycoca6
    echo "✅ kbuildsycoca6 completed"
fi

if command -v kbuildsycoca5 >/dev/null 2>&1; then
    echo "Running kbuildsycoca5..."
    kbuildsycoca5
    echo "✅ kbuildsycoca5 completed"
fi

echo ""
echo "📝 Diagnostic tips:"
echo "1. If any directories show as NOT FOUND, reinstall that component"
echo "2. If metadata files are missing, the installer needs to be fixed"
echo "3. Check permissions - files should be readable by your user"
echo "4. For look-and-feel, ensure it's owned by root:root (system-wide)"
echo "5. Icons/Cursors need index.theme file in root directory"
echo ""
echo "✅ Diagnostics complete!"
