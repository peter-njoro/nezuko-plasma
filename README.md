# Nezuko Plasma Theme

A custom KDE Plasma theme pack inspired by Nezuko Kamado — her pink kimono,
dark haori, and bamboo-green accents, reimagined as a Breeze-like plasma style
with light/dark variants and a Papirus-based pink icon pack.

## Contents

| Component | Directory | Description |
|-----------|-----------|-------------|
| Global theme | `look-and-feel/org.kde.nezuko.desktop/` | Ties plasma style, icons, colors, and cursor together |
| Plasma style (dark) | `plasma/Nezuko/` | Dark variant with glassy pink accents |
| Plasma style (light) | `plasma/Nezuko-Light/` | Light variant with cream/white tones |
| Icons | `icons/Nezuko-Icons/` | Papirus-based, pink, self-contained (16–256 px + scalable) |
| Cursors | `cursors/Nezuko-Cursors/` | Matching pink cursor theme |
| Color schemes | `plasma/Nezuko/colors/` + `plasma/Nezuko-Light/colors/` | Dark + light `.colors` files |
| Konsole scheme | `konsole/NezukoKamado.colorscheme` | Terminal color scheme |
| Splash | `nezuko-splash/` + `images/` | Animated standalone splash screen |

## Installation

### Quick start (recommended)

Clone the repo and run the installer. It detects your distro, installs any
missing build dependencies, copies all theme components, and refreshes the
system cache.

```bash
git clone https://github.com/peter-njoro/nezuko-plasma.git
cd nezuko-plasma
./install.sh
```

> The installer uses `sudo` only for system-wide packages and the global
> look-and-feel directory. Everything else is installed to `~/.local`.

### From pre-built KDE Store archives

If you have the archives in `pack/` (produced by `pack_kde_store.py`), you can
install without cloning or building:

```bash
./install_from_archives.sh            # user-local (~/.local)
./install_from_archives.sh --system   # system-wide (needs sudo)
```

### Manual install (component by component)

Copy the directories to the locations below. A logout/login is required for
 Plasma to pick up new themes.

```bash
# Plasma desktop themes
cp -r plasma/Nezuko        ~/.local/share/plasma/desktoptheme/
cp -r plasma/Nezuko-Light  ~/.local/share/plasma/desktoptheme/

# Icons and cursors
cp -r icons/Nezuko-Icons   ~/.local/share/icons/
cp -r cursors/Nezuko-Cursors ~/.local/share/icons/

# Color schemes
cp plasma/Nezuko/colors/Nezuko.colors        ~/.local/share/color-schemes/
cp plasma/Nezuko-Light/colors/Nezuko-Light.colors ~/.local/share/color-schemes/

# Global look-and-feel (system-wide)
sudo cp -r look-and-feel/org.kde.nezuko.desktop /usr/share/plasma/look-and-feel/

# Konsole
cp konsole/NezukoKamado.colorscheme ~/.local/share/konsole/

# Refresh caches
kbuildsycoca5 || kbuildsycoca6
```

## Applying the theme

Open **System Settings → Colors & Themes** and set:

- **Global Theme:** `Nezuko`
- **Plasma Style:** `Nezuko` (dark) or `Nezuko-Light`
- **Icons:** `Nezuko-Icons`
- **Cursors:** `Nezuko-Cursors`
- **Color Scheme:** `Nezuko Kamado` (dark) or `Nezuko Kamado Light`

## Regenerating components

### Rebuild the icon pack from Papirus sources

The icon pack is built from the Papirus icon theme (GPL-3.0) and recolored to
Nezuko's pink palette. You need a local checkout of Papirus:

```bash
PAPIRUS_SRC=/path/to/Papirus ./icons/Nezuko-Icons/build_icon_pack.sh
```

### Rebuild the light plasma style from the dark one

The light variant is generated programmatically from the dark SVGs. This keeps
both themes in sync:

```bash
python3 plasma/Nezuko-Light/dark_to_light.py plasma/Nezuko plasma/Nezuko-Light
```

### Produce KDE Store archives

```bash
python3 pack_kde_store.py --all
```

This generates `.metadata.json` and zip archives for each component in `pack/`,
ready to upload to the KDE Store.

## Diagnostics

If something is not rendering correctly, run the diagnostic script:

```bash
./diagnose.sh
```

## Uninstallation

```bash
./uninstall.sh
```

## Project phases

- **Phase 1 — Icons:** Papirus-based, pink, self-contained. See [`PHASE1_ICONS.md`](PHASE1_ICONS.md).
- **Phase 2 — Plasma style:** Dark + light variants. See [`PHASE2_PLASMA_STYLE.md`](PHASE2_PLASMA_STYLE.md).
- **Phase 3 — KDE Store packaging:** Archives and store manifests. See [`PHASE3_KDE_STORE.md`](PHASE3_KDE_STORE.md).
- **Project reference:** [`PROJECT_REFERENCE.md`](PROJECT_REFERENCE.md).

## Credits

Made for KDE Plasma fans. Inspired by Nezuko Kamado.