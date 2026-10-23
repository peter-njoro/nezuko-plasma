#!/usr/bin/env python3
"""Generate KDE Store-ready packaging for the Nezuko theme pack.

Produces, for each component:
  - a .metadata.json (KDE Store manifest)
  - a zip archive with the correct top-level layout

Archive layouts:
  plasma desktop theme : <name>/metadata.json + SVGs
  icon theme          : <name>/index.theme + SVGs/PNGs
  cursor theme        : <name>/index.theme + cursors
  color scheme        : <name>.colors
  look-and-feel       : <id>/metadata.json + contents/

Usage: python3 pack_kde_store.py [--all | <component>]
"""
import json
import os
import shutil
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "pack"
VERSION = "1.2.0"
AUTHOR = {"Name": "Peter Njoroge Chege", "Email": "peterchegen12@gmail.com"}
WEBSITE = "https://github.com/peter-njoro/nezuko-plasma"
LICENSE = "GPL-2.0-or-later"

COMPONENTS = {
    "plasma-dark": {
        "src": "plasma/Nezuko",
        "store_id": "plasma-desktoptheme-Nezuko",
        "name": "Nezuko Kamado (Dark)",
        "desc": "Nezuko-inspired dark KDE Plasma desktop theme with glassy dialogs, rounded corners, and shadows.",
        "category": "Plasma/Theme",
        "kpackage_structure": "Plasma/DesktopTheme",
    },
    "plasma-light": {
        "src": "plasma/Nezuko-Light",
        "store_id": "plasma-desktoptheme-Nezuko-Light",
        "name": "Nezuko Kamado (Light)",
        "desc": "Nezuko-inspired light KDE Plasma desktop theme with cream glassy dialogs and pale-pink accents.",
        "category": "Plasma/Theme",
        "kpackage_structure": "Plasma/DesktopTheme",
    },
    "icons": {
        "src": "icons/Nezuko-Icons",
        "store_id": "icontheme-Nezuko-Icons",
        "name": "Nezuko Icons",
        "desc": "MacTahoe-styled icon theme recolored to the Nezuko pink palette. Self-contained, based on Papirus.",
        "category": "IconTheme",
        "kpackage_structure": "KPackage/Generic",
    },
    "cursors": {
        "src": "cursors/Nezuko-Cursors",
        "store_id": "cursortheme-Nezuko-Cursors",
        "name": "Nezuko Cursors",
        "desc": "Pink-accented cursor theme derived from Adwaita.",
        "category": "CursorTheme",
        "kpackage_structure": "KPackage/Generic",
    },
    "colors-dark": {
        "src": "plasma/Nezuko/colors/Nezuko.colors",
        "store_id": "colorscheme-Nezuko-Dark",
        "name": "Nezuko Kamado Dark",
        "desc": "Dark color scheme: pink kimono on dark haori with bamboo-green accents.",
        "category": "ColorScheme",
        "kpackage_structure": "KPackage/Generic",
    },
    "colors-light": {
        "src": "plasma/Nezuko-Light/colors/Nezuko-Light.colors",
        "store_id": "colorscheme-Nezuko-Light",
        "name": "Nezuko Kamado Light",
        "desc": "Light color scheme: cream and pale pink with bamboo-green accents.",
        "category": "ColorScheme",
        "kpackage_structure": "KPackage/Generic",
    },
    "look-and-feel": {
        "src": "look-and-feel/org.kde.nezuko.desktop",
        "store_id": "lookandfeel-org.kde.nezuko.desktop",
        "name": "Nezuko",
        "desc": "Nezuko global look-and-feel theme (dark): plasma style, icons, cursors, color scheme, splash.",
        "category": " Plasma/LookAndServe",
        "kpackage_structure": "Plasma/LookAndServe",
    },
}


def metadata(comp):
    return {
        "KPlugin": {
            "Authors": [AUTHOR],
            "Name": comp["name"],
            "Description": comp["desc"],
            "Id": comp["store_id"],
            "Version": VERSION,
            "Category": comp["category"],
            "EnabledByDefault": True,
            "License": LICENSE,
            "Website": WEBSITE,
        },
        "KPackageStructure": comp["kpackage_structure"],
    }


def zip_directory(src_dir, name, extra_files=None, skip_suffixes=()):
    """Zip a directory as <name>/... plus optional extra top-level files.

    skip_suffixes: file suffixes to omit from the archive (e.g. PNG fallbacks
    that bloat the upload but aren't needed since KDE scales SVGs).
    """
    zip_path = OUT / f"{name}.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(Path(src_dir).rglob("*")):
            if p.is_file():
                if skip_suffixes and p.suffix in skip_suffixes:
                    continue
                arc = f"{name}/{p.relative_to(src_dir)}"
                z.write(p, arc)
        for path, arcname in (extra_files or []):
            z.write(path, f"{name}/{arcname}")


def build(comp_key):
    comp = COMPONENTS[comp_key]
    src = ROOT / comp["src"]
    if not src.exists():
        print(f"SKIP {comp_key}: {src} not found")
        return
    OUT.mkdir(parents=True, exist_ok=True)
    meta = metadata(comp)
    meta_path = OUT / f"{comp['store_id']}.metadata.json"
    meta_path.write_text(json.dumps(meta, indent=2) + "\n")

    if comp_key in ("plasma-dark", "plasma-light", "icons", "cursors", "look-and-feel"):
        # Plasma 6 desktop themes require metadata.json (metadata.desktop is
        # legacy). Add the JSON alongside the desktop file.
        extra = None
        if comp_key in ("plasma-dark", "plasma-light"):
            extra = [(str(meta_path), "metadata.json")]
        # Icon theme ships SVGs only by default; PNG fallbacks are huge and
        # KDE scales SVGs natively. Set INCLUDE_PNG=1 to add them.
        skip = (".png",) if comp_key == "icons" else ()
        zip_directory(src, comp["store_id"], extra_files=extra, skip_suffixes=skip)
    else:
        # color scheme: single file -> <id>/<basename>
        zip_path = OUT / f"{comp['store_id']}.zip"
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
            z.write(src, f"{comp['store_id']}/{src.name}")

    print(f"OK  {comp_key}: {comp['store_id']}.zip + .metadata.json")


def main():
    args = sys.argv[1:]
    if not args or "--all" in args:
        keys = list(COMPONENTS)
    else:
        keys = args
    for k in keys:
        if k not in COMPONENTS:
            print(f"Unknown component: {k}")
            continue
        build(k)


if __name__ == "__main__":
    main()