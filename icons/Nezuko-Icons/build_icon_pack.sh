#!/usr/bin/env bash
# build_icon_pack.sh
# Assemble the Nezuko-Icons theme from the Papirus source.
#
# Requires: Papirus source extracted at $PAPIRUS_SRC (default .../Papirus)
#           python3, rsvg-convert or inkscape (for --png)
#
# Usage: ./build_icon_pack.sh [--png]
set -euo pipefail

PAPIRUS_SRC="${PAPIRUS_SRC:-/tmp/papirus-tar/papirus-icon-theme-master/Papirus}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$SCRIPT_DIR"
BUILD_PNG="${1:-}"

CONTEXTS=(actions apps devices places mimetypes status categories emblems emotes)
# Sizes shipped as fixed-size dirs.
SIZES=(16 22 24 32 48 64 96 128 256)

echo "==> Source: $PAPIRUS_SRC"
[ -d "$PAPIRUS_SRC" ] || { echo "Papirus source not found at $PAPIRUS_SRC"; exit 1; }

# ---------------------------------------------------------------------------
# Clean output
# ---------------------------------------------------------------------------
echo "==> Cleaning $OUT"
for sz in "${SIZES[@]}"; do rm -rf "$OUT/${sz}x${sz}"; done
rm -rf "$OUT/scalable"
mkdir -p "$OUT/scalable"

# ---------------------------------------------------------------------------
# Symbolic layer: 16/22/24 (theming-intended, recolored)
# ---------------------------------------------------------------------------
echo "==> Symbolic layer (16/22/24)"
for sz in 16x16 22x22 24x24; do
    for ctx in "${CONTEXTS[@]}"; do
        src="$PAPIRUS_SRC/$sz/symbolic/$ctx"
        [ -d "$src" ] || continue
        python3 "$OUT/recolor_batch.py" "$src" "$OUT/$sz/$ctx" symbolic "$ctx"
    done
done

# ---------------------------------------------------------------------------
# Color layer: 32/48/64/96/128/256 (recolored with role-aware map)
# ---------------------------------------------------------------------------
echo "==> Color layer (32+)"
for sz in 32x32 48x48 64x64 96x96 128x128 256x256; do
    for ctx in "${CONTEXTS[@]}"; do
        src="$PAPIRUS_SRC/$sz/$ctx"
        [ -d "$src" ] || continue
        python3 "$OUT/recolor_batch.py" "$src" "$OUT/$sz/$ctx" color "$ctx"
    done
done

# ---------------------------------------------------------------------------
# Scalable directory: 48x48 system icons as the scalable base.
# KDE looks up scalable/<context>/<name>.svg and scales to any size.
# ---------------------------------------------------------------------------
echo "==> Scalable/ from 48x48 system icons"
for ctx in actions devices places mimetypes status; do
    src="$PAPIRUS_SRC/48x48/$ctx"
    [ -d "$src" ] || continue
    python3 "$OUT/recolor_batch.py" "$src" "$OUT/scalable/$ctx" color "$ctx"
done

# ---------------------------------------------------------------------------
# PNG fallbacks (optional, --png flag)
# ---------------------------------------------------------------------------
if [ "$BUILD_PNG" = "--png" ]; then
    echo "==> Generating PNG fallbacks"
    if ! command -v rsvg-convert >/dev/null 2>&1; then
        echo "rsvg-convert not found; install librsvg2-bin"
        exit 1
    fi
    for sz in "${SIZES[@]}"; do
        for ctx in "${CONTEXTS[@]}"; do
            src_dir="$OUT/$sz/$ctx"
            [ -d "$src_dir" ] || continue
            for svg in "$src_dir"/*.svg; do
                [ -f "$svg" ] || continue
                name="$(basename "${svg%.svg}")"
                rsvg-convert -w "$sz" -h "$sz" "$svg" -o "$src_dir/$name.png"
            done
        done
    done
fi

echo "==> Done. Icon pack assembled in $OUT"