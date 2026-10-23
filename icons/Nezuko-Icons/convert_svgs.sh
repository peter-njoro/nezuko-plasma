#!/bin/bash
# convert_svgs.sh
# Generate PNG fallbacks from SVG icons in the Nezuko-Icons theme.
# Prefers rsvg-convert, falls back to Inkscape. Runs in parallel.
set -euo pipefail

OUTDIR="."
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
SIZES=(16 22 24 32 48 64 96 128 256)

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

echo "🎨 Converting SVGs to PNG fallbacks (parallel=$JOBS)..."

# Worker script written to a temp file so xargs can invoke it in parallel subshells.
WORKER="$(mktemp)"
cat > "$WORKER" << 'WORKER_EOF'
#!/bin/bash
# args: svg size converter
svg="$1"; sz="$2"; converter="$3"
name="$(basename "${svg%.svg}")"
outdir="$(dirname "$svg")"
if [ "$converter" = "rsvg-convert" ]; then
    rsvg-convert -w "$sz" -h "$sz" "$svg" -o "$outdir/$name.png"
else
    inkscape "$svg" --export-type=png --export-filename="$outdir/$name.png" \
               --export-width="$sz" --export-height="$sz" >/dev/null 2>&1
fi
WORKER_EOF
chmod +x "$WORKER"

for sz in "${SIZES[@]}"; do
    szdir="${sz}x${sz}"
    [ -d "$szdir" ] || continue
    echo "  → size $sz"
    find "$szdir" -name "*.svg" -print0 | xargs -0 -P "$JOBS" -I {} "$WORKER" {} "$sz" "$CONVERTER"
done

rm -f "$WORKER"
echo "✅ All fallbacks generated"