# Phase 1 - Icon Pack Plan (MacTahoe-like, pink)

## Decision: base geometry = Papirus (open, flat rounded-squircle style closest to MacTahoe)

Papirus is the closest open-source equivalent to macOS Big Sur/Monterey (MacTahoe):
flat, rounded-square glyphs, vibrant fills, subtle gradients. NOT breeze (which is KDE's
own flatter, more angular style). GPL-3.0, from PapirusDevelopmentTeam.

## Discovery: Papirus ships two layers

1. **Color layer** (`<size>/<context>/*.svg`): hardcoded brand colors.
   e.g. `48x48/apps/firefox.svg` has `fill:#ffde3f`, `fill:#8357cd`, `fill:#f74e66`
   — Firefox's actual logo colors. Cannot be naively recolored.
2. **Symbolic layer** (`<size>/symbolic/<context>/*.svg`): uses `fill:currentColor` +
   a `<style>` block with `ColorScheme-*` CSS classes. Designed for theming.
   Present at 16x16, 22x22, 24x24 only. ~1400 icons total, all `currentColor`.

## Qt rendering test (critical finding)

Tested with Qt6 QSvgRenderer (what Plasma uses):
- `fill:currentColor` with NO `color:` set → renders BLACK (currentColor defaults to black).
- `fill:currentColor` WITH `color:#444444` set via CSS → renders the CSS color.
- Hardcoded `fill:#5294e2` → renders blue as authored.
- Recoloring symbolic SVGs (replace currentColor + CSS colors with pink) → renders pink correctly.

=> **Strategy: use the symbolic layer as the base, recolor its `currentColor` and CSS
   color roles to the pink palette.** This is the theming-intended path and produces
   consistent pink across all system icons.

## Coverage problem

Symbolic exists only at 16/22/24. KDE/Qt needs 32/48/64/96/128/256 too.
Options:
- A) Recolor the color layer for >=32 (loses brand-correctness but gets pink).
- B) Upscale symbolic 24 -> larger sizes (loses detail).
- C) Recolor color layer for >=32 BUT skip brand-accurate app logos (use generic app glyph).

Chosen: **Hybrid** —
- 16/22/24: symbolic layer, recolored (perfect for small sizes, the main panel/icon sizes).
- 32/48/64/96/128/256: color layer, recolored.

## Recolor strategy (icons/Nezuko-Icons/recolor_batch.py)

- Symbolic layer: rewrite the CSS role colors to the pink palette + set
  `fill:currentColor` -> primary pink.
- Color layer: ALL contexts recolored to the pink palette — apps included.
  Brand logos (Firefox, Chrome, etc.) are pinked too, per the theme design.
  Neutral fills (white/gray/black) -> pink family; saturated colors ->
  primary pink; near-black -> dark pink.

## Pink palette

Anchor #FF69B4. Palette:
- Primary: #FF69B4
- Light: #FFB6D2, #FFD6E6, #FFC0CB
- Dark: #E0529A, #B83A78
- Neutral bg: #F5E6F0 (light theme), #2E2A2A (dark theme)
- Accent green (bamboo): #4CAF50
- Negative: #FF4081

## Sizes to ship

Standard freedesktop/KDE sizes: 8, 16, 22, 24, 32, 42, 48, 64, 84, 96, 128, 256
Plus @2x variants for HiDPI.

## Contexts

apps, actions, devices, places, mimetypes, status, categories, emblems, emotes,
panel, preferences, animations.

## Deliverables

1. `icons/Nezuko-Icons/` fully populated with SVGs at all sizes + PNG fallbacks.
2. `icons/Nezuko-Icons/index.theme` rewritten (Inherits=breeze only as last fallback).
3. `icons/Nezuko-Icons/recolor.py` — the recolor pipeline (role-aware map).
4. `icons/Nezuko-Icons/convert_svgs.sh` — PNG generation (rsvg-convert).
5. Remove install-time recolor hack from `install.sh`.

## Open question for user (RESOLVED)

How to handle brand-specific app logos (Firefox, Chrome, etc.) that Papirus colors
authentically? Options:
- (a) recolor everything pink (loses brand identity)
- (b) keep brand colors for known apps, pink everything else
- (c) recolor brand fills to a pink tint

**Decision: (a) — recolor everything pink.** Brand logos are pinked too, per the
theme design. The recolor logic in `recolor_batch.py` / `recolor.py` applies the
same pink palette to all contexts with no brand exceptions.