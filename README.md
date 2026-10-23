# Nezuko Plasma Theme

A custom KDE Plasma theme pack inspired by Nezuko Kamado — pink kimono,
dark haori, and bamboo-green accents.

Includes:
- Global look-and-feel theme
- Plasma desktop themes (dark + light)
- Nezuko-Icons (MacTahoe-styled, pink, self-contained)
- Nezuko-Cursors
- Color schemes (dark + light)
- Splash screen

---

## Installation

### From source (local install)

```bash
git clone https://github.com/peter-njoro/nezuko-plasma.git
cd nezuko-plasma
./install.sh
```

### From KDE Store archives

```bash
python3 pack_kde_store.py --all
./install_from_archives.sh            # user-local (~/.local)
./install_from_archives.sh --system   # system-wide (needs sudo)
```

## Apply the theme

System Settings → Colors & Themes

- Global Theme: `Nezuko`
- Plasma Style: `Nezuko` (dark) or `Nezuko-Light`
- Icons: `Nezuko-Icons`
- Cursors: `Nezuko-Cursors`
- Color Scheme: `Nezuko Kamado` (dark) or `Nezuko Kamado Light`

## Regenerating components

```bash
# Rebuild the icon pack from Papirus sources
PAPIRUS_SRC=/path/to/Papirus ./icons/Nezuko-Icons/build_icon_pack.sh

# Rebuild the light plasma style from the dark one
python3 plasma/Nezuko-Light/dark_to_light.py plasma/Nezuko plasma/Nezuko-Light

# Produce KDE Store archives
python3 pack_kde_store.py --all
```

## Uninstallation

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Project phases

- Phase 1 — Icons: Papirus-based, pink, self-contained (`PHASE1_ICONS.md`)
- Phase 2 — Plasma style: dark + light variants (`PHASE2_PLASMA_STYLE.md`)
- Phase 3 — KDE Store packaging (`PHASE3_KDE_STORE.md`)
- Project reference: `PROJECT_REFERENCE.md`

## Credits

Made for KDE Plasma fans. Inspired by Nezuko Kamado.