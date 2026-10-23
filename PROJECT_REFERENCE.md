# Nezuko Plasma Theme - Project Reference

> Generated: 2026-10-23
> This doc is a reference for the project in case context is exhausted.
> Keep it updated as work progresses.

## Repository layout

```
/home/peter/projects/nezuko-plasma
├── background.mp4 / background.png          # desktop wallpaper
├── cursors/Nezuko-Cursors/                  # cursor theme (CMake-built, Adwaita-derived)
│   ├── index.theme
│   └── cursors/src/svg/*.svg                # source SVGs + config templates
├── icons/Nezuko-Icons/                       # icon theme
│   ├── index.theme                           # Inherits=breeze, dirs 16..128 + scalable
│   ├── convert_svgs.sh                      # SVG->PNG fallback generator
│   ├── scalable/{apps,actions,devices,mimetypes,places,status}/*.svg
│   └── 48x48/*.png                          # only a few PNGs exist today
├── images/nezuko.svg, background.png
├── konsole/NezukoKamado.colorscheme
├── look-and-feel/org.kde.nezuko.desktop/    # global theme
│   ├── metadata.desktop                     # PlasmaStyle=Nezuko, Icons=Nezuko-Icons, Colors=Nezuko
│   └── contents/{defaults/kdeglobals, splash/, previews/preview.png}
├── nezuko-splash/                           # standalone Qt splash (qmake/CMake)
├── plasma/Nezuko/                           # plasma style
│   ├── metadata.desktop
│   ├── colors/Nezuko.colors                 # dark pink color scheme
│   ├── dialogs/background.svg
│   ├── opaque/dialogs/background.svg
│   ├── translucent/dialogs/background.svg
│   ├── shadows/shadow-*.svg
│   ├── widgets/background.svg, tasks.svg, panel-background.svg
│   └── widgets/shadows/shadow-*.svg
├── install.sh                               # installer (distro-aware, builds splash)
├── uninstall.sh
├── diagnose.sh
├── LICENSE, README.md
└── .gitignore, .gitmodules
```

## Current state (as of 2026-10-23)

- **Icons**: only 13 custom pink SVGs; everything else inherited from system `breeze` at
  install time via `install.sh` recolor step (sed on `fill:`). Fragile, partial, not
  self-contained.
- **Plasma style**: single dark glassy-pink theme. No light variant. SVGs use hardcoded
  pink gradients (#FF69B4 family), not color-scheme variables.
- **Cursors**: full set, CMake-built, `theme-purple` variant exists.
- **Packaging**: manual install.sh only. No KDE Store archives / `.metadata.json`.
- Git: working tree has modified `install.sh` (uncommitted).

## Color palette (pink anchor)

- Anchor: `#FF69B4` (hot pink)
- Light pink: `#FFC0CB`, `#FFB6D2`, `#FFD6E6`
- Dark bg: `#2E2A2A`, `#3A343A`
- Accent green (bamboo): `#4CAF50`

## Planned work (phases)

### Phase 1 - Icons: MacTahoe-like, pink, self-contained (DONE)
- Base geometry = **Papirus** (open, flat rounded-squircle style closest to MacTahoe).
  Source: PapirusDevelopmentTeam/papirus-icon-theme (GPL-3.0).
- Papirus has TWO layers: color (hardcoded brand fills) + symbolic (`fill:currentColor` +
  ColorScheme-* CSS classes, theming-intended). Symbolic exists at 16/22/24 only (~1400 icons).
- Qt6 QSvgRenderer test: `currentColor` renders BLACK unless `color:` is set in CSS;
  recoloring symbolic SVGs to pink works correctly.
- Strategy: 16/22/24 use symbolic layer recolored; 32+ use color layer with role-aware recolor.
- Recolor logic (icons/Nezuko-Icons/recolor_batch.py):
  - ALL contexts recolored to the pink palette, apps included.
  - Brand logos (Firefox/Chrome) are pinked too (user decision).
  - Neutral fills -> pink family; saturated colors -> primary pink;
    near-black -> dark pink.
- Full plan + open questions: `PHASE1_ICONS.md`.
- Tooling: `build_icon_pack.sh` (assembles pack), `recolor_batch.py` (recolored),
  `gen_index_theme.py` (writes index.theme), `convert_svgs.sh` (PNG fallbacks).
- Output: `icons/Nezuko-Icons/` — 92,506 SVGs + 88,919 PNGs at sizes
  16/22/24/32/48/64/96/128 + scalable, 61 directory sections in index.theme.
  Self-contained; Inherits=breeze,hicolor only as last-resort fallback.

### Phase 2 - Plasma style: Breeze-like, light + dark (DONE)
- Two sibling desktop themes: `plasma/Nezuko` (dark) + `plasma/Nezuko-Light` (light),
  mirroring how Breeze ships breeze-dark and breeze-light.
- Plasma's QSvgRenderer does not support CSS class selectors, so a single
  parameterized SVG can't switch variants — separate themes is the proven path.
- Light variant derived via `plasma/Nezuko-Light/dark_to_light.py`.
- Full plan: `PHASE2_PLASMA_STYLE.md`.
- Output: `plasma/Nezuko/` + `plasma/Nezuko-Light/`, each with dialogs, opaque,
  translucent, widgets, shadows, colors, metadata.

### Phase 3 - KDE Store packaging (DONE)
- `pack_kde_store.py` generates `.metadata.json` + `.zip` for all 7 components.
- `install_from_archives.sh` installs from the archives (user or --system).
- Plasma 6 desktop themes ship `metadata.json` (+ legacy `metadata.desktop`).
- Full plan: `PHASE3_KDE_STORE.md`.
- Output: `pack/` (regenerated on demand; gitignored).

## Key files / commands

- Install: `./install.sh` (needs inkscape, librsvg, qt6, cmake)
- Icon PNG gen: `icons/Nezuko-Icons/convert_svgs.sh`
- Git repo: https://github.com/peter-njoro/nezuko-plasma

## Decisions made

- Icons: NOT breeze-based. MacTahoe-like geometry, pink palette retained.
- Scope order: reference doc -> Phase 1 icons -> Phase 2 plasma style -> Phase 3 packaging.