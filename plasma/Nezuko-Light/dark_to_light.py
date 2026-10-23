#!/usr/bin/env python3
"""Transform dark Nezuko plasma SVGs into the light variant.

Swaps dark colors for cream/white equivalents, strips blur filters for a
solid Breeze-like panel, and adjusts rect geometry to fill the full canvas
with a small edge curve and outline. Used to derive plasma/Nezuko-Light/**
from plasma/Nezuko/**.
"""
import re
import sys
from pathlib import Path

def transform(text: str) -> str:
    # 1. Strip feGaussianBlur filters — light theme uses solid panels like Breeze
    text = re.sub(
        r'\s*<filter[^>]*>.*?</filter>',
        '',
        text,
        flags=re.DOTALL,
    )

    # 2. Remove filter= references on rects (the blur is gone)
    text = re.sub(r'\s*filter="url\([^)]*\)"', '', text)

    # 3. Normalize rect geometry: full-canvas size with small edge curve + outline.
    #    Breeze panels are solid, slightly rounded, with a thin outline.
    #    We rewrite any rect that has a blur filter remnant or inset padding
    #    to fill its viewBox with rx=6 (panel) or rx=12 (dialog).
    def _expand_rect(m):
        full_w = m.group('w')
        full_h = m.group('h')
        # Determine if this is a dialog (large) or panel (small) by dimensions
        try:
            w_val = float(full_w)
            h_val = float(full_h)
        except ValueError:
            return m.group(0)
        rx = '20' if (w_val >= 200 and h_val >= 200) else '10'
        return (
            f'<rect x="0" y="0" width="{full_w}" height="{full_h}" '
            f'rx="{rx}" ry="{rx}"'
        )

    # Match <rect ...> opening tag, capture width/height attributes
    text = re.sub(
        r'<rect\b[^>]*\bwidth="(?P<w>[^"]+)"[^>]*\bheight="(?P<h>[^"]+)"[^>]*>',
        _expand_rect,
        text,
    )

    # 4. Swap dark colors -> light equivalents
    repls = [
        # Dark panel/opaque gradient stops -> cream with pale pink
        ("#3A2A3A", "#FFF5FA"),
        ("#2E2A2E", "#FFE4F0"),
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
        # outline strokes: dark panel outline -> light gray
        ("#1A1A1A", "#E0E0E0"),
    ]
    for a, b in repls:
        text = text.replace(a, b)

    # 5. Fix the CSS color-scheme block: swap dark scheme colors for light ones
    text = text.replace('.ColorScheme-ViewBackground{color:#3A2A3A}',
                         '.ColorScheme-ViewBackground{color:#FFFFFF}')
    text = text.replace('.ColorScheme-ViewText{color:#FFFFFF}',
                         '.ColorScheme-ViewText{color:#2E2A2A}')
    text = text.replace('.ColorScheme-ButtonText{color:#2E2A2A}',
                         '.ColorScheme-ButtonText{color:#2E2A2A}')  # unchanged
    text = text.replace('.ColorScheme-ButtonBackground{color:#FFB6D2}',
                         '.ColorScheme-ButtonBackground{color:#FFD6E6}')
    text = text.replace('.ColorScheme-ButtonHover{color:#FF69B4}',
                         '.ColorScheme-ButtonHover{color:#FF69B4}')  # unchanged
    text = text.replace('.ColorScheme-ViewHover{color:#FF69B4}',
                         '.ColorScheme-ViewHover{color:#FF69B4}')  # unchanged
    text = text.replace('.ColorScheme-ViewFocus{color:#FF69B4}',
                         '.ColorScheme-ViewFocus{color:#FF69B4}')  # unchanged
    text = text.replace('.ColorScheme-Background{color:#2E2A2A}',
                         '.ColorScheme-Background{color:#FFFFFF}')
    text = text.replace('.ColorScheme-Highlight{color:#FF69B4}',
                         '.ColorScheme-Highlight{color:#FFE4F0}')

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