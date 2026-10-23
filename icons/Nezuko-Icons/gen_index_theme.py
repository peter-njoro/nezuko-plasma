#!/usr/bin/env python3
"""Generate index.theme for Nezuko-Icons from the actual directory structure."""
import sys
from pathlib import Path

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

CONTEXT_NAMES = {
    "actions": "Actions", "apps": "Applications", "categories": "Categories",
    "devices": "Devices", "emblems": "Emblems", "emotes": "Emotes",
    "mimetypes": "MimeTypes", "places": "Places", "status": "Status",
    "panel": "Panel", "preferences": "Preferences", "animations": "Animations",
}

lines = []
lines.append("[Icon Theme]")
lines.append("Name=Nezuko-Icons")
lines.append("Comment=Nezuko pink MacTahoe-styled icon theme")
lines.append("Inherits=breeze,hicolor")
lines.append("Example=folder")
lines.append("DisplayDepth=32")
lines.append("FollowsColorScheme=true")
lines.append("DesktopDefault=48")
lines.append("DesktopSizes=16,22,24,32,48,64,96,128,256")
lines.append("ToolbarDefault=22")
lines.append("ToolbarSizes=16,22,24,32,48")
lines.append("MainToolbarDefault=22")
lines.append("MainToolbarSizes=16,22,24,32,48")
lines.append("SmallDefault=16")
lines.append("SmallSizes=16,22,24,32,48")
lines.append("PanelDefault=48")
lines.append("PanelSizes=16,22,24,32,48,64")
lines.append("DialogDefault=48")
lines.append("DialogSizes=16,22,24,32,48,64")

# Collect size dirs present (e.g. 16x16, 48x48).
size_dirs = []
for d in sorted(OUT.iterdir()):
    if not d.is_dir() or d.name == "scalable" or d.name == "__pycache__":
        continue
    parts = d.name.split("x")
    if len(parts) == 2 and parts[0].isdigit() and parts[1].isdigit():
        size_dirs.append(d)
size_dirs.sort(key=lambda d: int(d.name.split("x")[0]))

# Build Directories list and per-directory sections.
dir_entries = []
for sd in size_dirs:
    sz = int(sd.name.split("x")[0])
    for ctx in sorted(sd.iterdir()):
        if not ctx.is_dir():
            continue
        rel = f"{sd.name}/{ctx.name}"
        dir_entries.append(rel)
        lines.append("")
        lines.append(f"[{rel}]")
        lines.append(f"Size={sz}")
        lines.append(f"Context={CONTEXT_NAMES.get(ctx.name, ctx.name.title())}")
        lines.append("Type=Fixed")

# scalable dir
for ctx in sorted((OUT / "scalable").iterdir()):
    if not ctx.is_dir():
        continue
    rel = f"scalable/{ctx.name}"
    dir_entries.append(rel)
    lines.append("")
    lines.append(f"[{rel}]")
    lines.append("Size=48")
    lines.append("MinSize=8")
    lines.append("MaxSize=512")
    lines.append(f"Context={CONTEXT_NAMES.get(ctx.name, ctx.name.title())}")
    lines.append("Type=Scalable")

lines.insert(8, "Directories=" + ",".join(dir_entries))

(OUT / "index.theme").write_text("\n".join(lines) + "\n")
print(f"Wrote {OUT / 'index.theme'} ({len(dir_entries)} directories)")