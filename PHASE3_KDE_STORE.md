# Phase 3 - KDE Store Packaging

## Goal

Produce KDE Store-ready archives for every component of the Nezuko theme
pack, each with a `.metadata.json` manifest, plus an installer that deploys
from those archives.

## KDE Store packaging rules (Plasma 6)

- Plasma 6 uses `kpackage`. A desktop theme needs `metadata.json` with
  `"KPackageStructure": "Plasma/DesktopTheme"`. Legacy `metadata.desktop`
  is still accepted for porting.
- Look-and-Feel packages need `"KPackageStructure": "Plasma/LookAndServe"`.
- Icon/cursor/color themes use `KPackage/Generic`.
- Each archive extracts to a top-level folder named after the theme id.
- The `Id` in the metadata must match the archive's top-level folder name.

## Tooling

- `pack_kde_store.py` — generates `.metadata.json` + `.zip` for each component.
- `install_from_archives.sh` — installs from the archives (user or `--system`).

## Components produced (in `pack/`)

| Archive | Size | Contents |
|---|---|---|
| `plasma-desktoptheme-Nezuko.zip` | 9.5K | dark plasma style + metadata.json/desktop |
| `plasma-desktoptheme-Nezuko-Light.zip` | 11K | light plasma style + metadata.json/desktop |
| `icontheme-Nezuko-Icons.zip` | 114M | 92,506 SVGs (PNG fallbacks omitted by default) |
| `cursortheme-Nezuko-Cursors.zip` | 214K | cursor theme |
| `colorscheme-Nezuko-Dark.zip` | 702B | single .colors file |
| `colorscheme-Nezuko-Light.zip` | 715B | single .colors file |
| `lookandfeel-org.kde.nezuko.desktop.zip` | 42M | global theme + splash + preview |

Each has a matching `.metadata.json` with KPlugin metadata + KPackageStructure.

## Regenerating

```bash
python3 pack_kde_store.py --all
```

To include PNG fallbacks in the icon archive (adds ~700MB), set
`INCLUDE_PNG=1` — currently omitted because KDE scales SVGs natively.

## Installing

```bash
./install_from_archives.sh            # user-local (~/.local)
./install_from_archives.sh --system   # system-wide (needs sudo)
```

## Verified

- All 7 archives extract to correctly-named top-level folders.
- Plasma theme archives contain both `metadata.json` (Plasma 6) and
  `metadata.desktop` (legacy).
- Color scheme archives install as `<id>/<id>.colors`.
- Dry-run install to /tmp/test-* populated all four destination roots.