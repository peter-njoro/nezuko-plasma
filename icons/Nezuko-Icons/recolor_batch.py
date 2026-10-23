#!/usr/bin/env python3
"""Batch recolor: copy all *.svg in SRC_DIR (flat) to DST_DIR, recolored.

Usage: recolor_batch.py <src_dir> <dst_dir> <mode>
  mode: symbolic | color

Fast: single process, regex over whole tree.
"""
import re
import sys
from pathlib import Path

PINK = {
    "primary": "#FF69B4", "light": "#FFB6D2", "lighter": "#FFD6E6",
    "pale": "#FFC0CB", "deep": "#E0529A", "deep2": "#B83A78",
    "bg_light": "#F5E6F0", "bg_dark": "#2E2A2A", "accent": "#4CAF50",
    "negative": "#FF4081", "neutral": "#FFA7D7", "white": "#FFFFFF",
    "black": "#2E2A2A",
}
ROLE_MAP = {
    "Text": PINK["black"], "Highlight": PINK["primary"],
    "NeutralText": PINK["neutral"], "PositiveText": PINK["accent"],
    "NegativeText": PINK["negative"],
}
NEUTRAL_MAP = {
    "#ffffff": PINK["lighter"], "#fafafa": PINK["pale"], "#eaeaea": PINK["pale"],
    "#e4e4e4": PINK["light"], "#c2c2c2": PINK["light"], "#cccccc": PINK["light"],
    "#8e8e8e": PINK["deep"], "#676767": PINK["deep2"], "#4f4f4f": PINK["deep2"],
    "#3f3f3f": PINK["deep2"], "#323232": PINK["deep2"], "#727272": PINK["deep2"],
    "#1d344f": PINK["bg_dark"], "#000000": PINK["bg_dark"],
}
WARM_BRAND = {"#ffba36", "#f9bd30", "#ffde3f", "#ffcc19", "#ffa507",
              "#ffb300", "#ff9800", "#ffce41", "#ffeb3b"}
RED_BRAND = {"#e25252", "#bf4b4b", "#ec407a", "#f06292", "#eb6637"}


def recolor_symbolic(text):
    def css_sub(m):
        inner = m.group(1)
        for role, color in ROLE_MAP.items():
            inner = re.sub(
                r"\.ColorScheme-" + role + r"\s*\{[^}]*\}",
                ".ColorScheme-" + role + "{color:" + color + ";}", inner)
        return "<style id=\"current-color-scheme\" type=\"text/css\">" + inner + "</style>"
    text = re.sub(r"<style id=\"current-color-scheme\" type=\"text/css\">(.*?)</style>",
                  css_sub, text, flags=re.DOTALL)
    text = re.sub(r"fill:currentColor", "fill:" + PINK["primary"], text)
    return text


def recolor_color_layer(text, context="apps"):
    """Recolor a color-layer SVG.

    - apps: keep brand colors (Firefox blue, Chrome red, etc.) so logos stay
      recognizable; only neutral fills (white/gray/black) are pinkified.
    - everything else (places/devices/mimetypes/status/actions): Papirus uses a
      system palette of blues/teals/purples that are NOT brands, so recolor all
      saturated colors to the pink palette.
    """
    def repl(m):
        c = m.group(0)
        hexpart = c[5:].lower()
        if hexpart in NEUTRAL_MAP:
            return "fill:" + NEUTRAL_MAP[hexpart]
        if context == "apps":
            return c  # keep brand colors
        # non-app contexts: recolor everything to pink family
        if hexpart in WARM_BRAND:
            return "fill:" + PINK["primary"]
        if hexpart in RED_BRAND:
            return "fill:" + PINK["deep"]
        # blue/teal/purple system palette -> pink
        r = int(hexpart[1:3], 16)
        g = int(hexpart[3:5], 16)
        b = int(hexpart[5:7], 16)
        # saturated non-neutral color -> pink
        mx, mn = max(r, g, b), min(r, g, b)
        if mx - mn > 40 and mx > 60:
            return "fill:" + PINK["primary"]
        # near-black -> dark pink
        if mx < 90:
            return "fill:" + PINK["deep2"]
        return c
    return re.sub(r"fill:#[0-9a-fA-F]{6}", repl, text)


def process(src, dst, mode, context="apps"):
    text = src.read_text(encoding="utf-8", errors="replace")
    if mode == "symbolic":
        out = recolor_symbolic(text)
    else:
        out = recolor_color_layer(text, context)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(out, encoding="utf-8")


def main():
    src_dir = Path(sys.argv[1])
    dst_dir = Path(sys.argv[2])
    mode = sys.argv[3]
    context = sys.argv[4] if len(sys.argv) > 4 else "apps"
    dst_dir.mkdir(parents=True, exist_ok=True)
    for svg in sorted(src_dir.glob("*.svg")):
        process(svg, dst_dir / svg.name, mode, context)


if __name__ == "__main__":
    main()