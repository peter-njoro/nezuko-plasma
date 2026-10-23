#!/usr/bin/env python3
"""Transform dark Nezuko plasma SVGs into the light variant.

Swaps the glassy pink gradients for cream/white gradients, keeps the pink
identity on accents, and lightens the drop shadows. Used to derive
plasma/Nezuko-Light/** from plasma/Nezuko/**.
"""
import re
import sys
from pathlib import Path

# exact string replacements applied to every light SVG
REPLACEMENTS = []  # unused; transform() uses inline list below

def transform(text: str) -> str:
    # Case-insensitive exact replacement of gradient stop colors.
    # The panel/opaque dialog use opaque hex stops; the dialogs use rgba stops.
    # We want the light variant to read cream/white with a pale pink tint,
    # while keeping the pink identity on accents.
    repls = [
        # rgba glassy stops -> cream/white with pale pink
        ("rgba(255,182,193,0.85)", "rgba(255,255,255,0.92)"),
        ("rgba(255,182,193,0.8)",  "rgba(255,255,255,0.90)"),
        ("rgba(255,192,203,0.7)",  "rgba(255,255,255,0.85)"),
        ("rgba(255,105,180,0.7)",  "rgba(245,230,240,0.60)"),
        ("rgba(255,105,180,0.6)",  "rgba(245,230,240,0.50)"),
        ("rgba(255,105,180,0.5)",  "rgba(245,230,240,0.40)"),
        ("rgba(255,105,180,0.4)",  "rgba(245,230,240,0.30)"),
        # opaque hex stops (panel + opaque dialog) -> cream with pale pink
        ("#ffb6c1", "#FFFFFF"),
        ("#ff69b4", "#FFE4F0"),
        ("#FFB6D2", "#FFFFFF"),
        ("#FF69B4", "#FFE4F0"),
        # lighter shadows for light backgrounds
        ("rgba(0,0,0,0.45)", "rgba(0,0,0,0.18)"),
        ("rgba(0,0,0,0.4)",  "rgba(0,0,0,0.18)"),
    ]
    for a, b in repls:
        text = text.replace(a, b)
    return text

def main():
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    for p in src.rglob("*.svg"):
        rel = p.relative_to(src)
        out = dst / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(transform(p.read_text(encoding="utf-8")), encoding="utf-8")
        print("light:", rel)

if __name__ == "__main__":
    main()