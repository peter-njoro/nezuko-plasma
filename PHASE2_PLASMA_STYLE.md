# Phase 2 - Plasma Style: Breeze-like, Light + Dark

## Goal

Refactor the existing `plasma/Nezuko/` style so it behaves like Breeze: one plasma
style that works for both light and dark color schemes, driven by Qt color roles
rather than hardcoded hex values.

## Current state

`plasma/Nezuko/` has:
- `metadata.desktop` (single theme, no variants)
- `colors/Nezuko.colors` — dark pink scheme (hardcoded #FF69B4 family)
- `dialogs/background.svg`, `opaque/dialogs/background.svg`,
  `translucent/dialogs/background.svg` — glassy pink gradients, hardcoded
- `widgets/background.svg`, `tasks.svg`, `panel-background.svg` — hardcoded
- `shadows/shadow-*.svg` — generic dark shadows
- `widgets/shadows/shadow-*.svg`

All SVGs use hardcoded `rgba(255,105,180,...)` etc. They do not respond to the
color scheme at all.

## Breeze approach

Breeze's plasma style SVGs reference colors via Qt's `ColorScheme` QML types and
the `KColorScheme` / `Palette` mechanisms. In Plasma's `Frame` / `Panel` / `Button`
SVGs, colors come from the active color scheme through:

1. `fill="currentColor"` + a `color:` CSS rule sourced from the color scheme, OR
2. Qt's `Palette` role binding in the QML that instantiates the SVG.

For a plasma style (desktoptheme), the mechanism is:
- The SVG is rendered by `QSvgRenderer` in the widget's paint engine.
- Plasma sets the widget's palette (`QPalette`) from the active color scheme.
- SVGs can use `currentColor` and rely on the widget's palette being applied.

## Plan

1. **Parameterize the existing SVGs** — replace hardcoded pink with:
   - `fill="currentColor"` for foreground/accent elements
   - `stroke="currentColor"` for borders
   - Keep gradients but drive stop colors from `currentColor` where possible
   - Add a `<style>` block mirroring Papirus's `ColorScheme-*` classes, mapped
     to the Nezuko palette roles.

2. **Add a light color scheme** — `colors/Nezuko-Light.colors`:
   - Light backgrounds (#FFFFFF / #F5E6F0)
   - Dark text (#2E2A2A)
   - Pink accents (#FF69B4)
   - Adjust `Colors:View`, `Colors:Window`, `Colors:Header`, `Colors:Button`,
     `Colors:Menu`, `Colors:Toolbar`, `Colors:Tooltip`, etc.

3. **Adjust shadows** — light theme needs lighter shadows; keep dark ones for dark.

4. **Update `metadata.desktop`** to declare both opaque and translucent dialog
   variants and ensure both are wired.

5. **Test** — render both schemes through QSvgRenderer with the appropriate
   palettes and verify contrast.

## Deliverables

- `plasma/Nezuko/dialogs/background.svg` (parameterized)
- `plasma/Nezuko/opaque/dialogs/background.svg`
- `plasma/Nezuko/translucent/dialogs/background.svg`
- `plasma/Nezuko/widgets/*.svg` (panel, tasks, background)
- `plasma/Nezuko/shadows/*.svg` (light + dark aware)
- `plasma/Nezuko/colors/Nezuko.colors` (dark, refined)
- `plasma/Nezuko/colors/Nezuko-Light.colors` (new)

## Verification

- Render each key SVG under a dark palette and a light palette via the Qt6
  QSvgRenderer test harness; check that foreground contrasts background.
- Apply in a Plasma session (or Plasma via KWin) and visually verify.