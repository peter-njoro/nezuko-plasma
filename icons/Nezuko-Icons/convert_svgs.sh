#!/bin/bash

# convert_svgs.sh
# Generate PNG fallbacks from SVG icons
# Prefers rsvg-convert, falls back to Inkscape
# Maintains freedesktop-style subfolder structure

set -euo pipefail

# Sizes to export
SIZES=(16 32 48 64 128)

# Output base directory
OUTDIR="."
mkdir -p "$OUTDIR"

# Choose converter
if command -v rsvg-convert &> /dev/null; then
    CONVERTER="rsvg-convert"
    echo "🎨 Using rsvg-convert for SVG → PNG conversion"
elif command -v inkscape &> /dev/null; then
    CONVERTER="inkscape"
    echo "🎨 rsvg-convert not found, using Inkscape for SVG → PNG conversion"
else
    echo "❌ Neither rsvg-convert nor Inkscape is installed. Please install one."
    exit 1
fi

echo "🎨 Converting SVGs to PNG fallbacks..."

# Find all SVGs in scalable directories
find scalable -type f -name "*.svg" | while read -r svg; do
    # Example: scalable/apps/firefox.svg
    relpath="${svg#scalable/}"       # → apps/firefox.svg
    subdir="$(dirname "$relpath")"   # → apps
    name="$(basename "${relpath%.svg}")" # → firefox

    for size in "${SIZES[@]}"; do
        # Build output directory based on index.theme structure
        outdir="$OUTDIR/${size}x${size}/$subdir"
        mkdir -p "$outdir"

        outfile="$outdir/$name.png"

        echo "➡️ $relpath → $outfile (${size}x${size})"

        if [[ "$CONVERTER" == "rsvg-convert" ]]; then
            rsvg-convert -w $size -h $size "$svg" -o "$outfile"
        else
            inkscape "$svg" --export-type=png --export-filename="$outfile" \
                    --export-width=$size --export-height=$size
        fi
    done
done

echo "✅ All fallbacks generated"
