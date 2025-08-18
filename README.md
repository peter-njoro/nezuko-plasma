# 🌸 Nezuko Plasma Theme

A custom **KDE Plasma theme** inspired by Nezuko 🌸  
Includes:
- Global theme
- Plasma style
- Cursors
- Icons
- Color scheme

---

## 🖼️ Preview

![Nezuko Plasma Theme Screenshot](look-and-feel/org.kde.nezuko/contents/previews/Screenshot.png)

---

## 📦 Installation

**Before you begin:**  
Make sure you have `inkscape` and `rsvg-convert` installed, as they are required for icon conversion.

Install them on Debian/Ubuntu with:
```bash
sudo apt update
sudo apt install inkscape librsvg2-bin
```

**Clone this repository:**
```bash
git clone https://github.com/peter-njoro/nezuko-plasma.git
cd nezuko-plasma
```

1. Make the installer script executable:
```bash
chmod +x install.sh
```

2. Run the provided installer script:

```bash
./install.sh
```
## The script will:
- Copy cursors `→ ~/.local/share/icons/Nezuko-Cursors`
- Copy icons `→ ~/.local/share/icons/Nezuko-Icons`
- Copy plasma style `→ ~/.local/share/plasma/desktoptheme/Nezuko`
- Copy global theme `→ ~/.local/share/plasma/look-and-feel/org.kde.nezuko`
- Copy color scheme `→ ~/.local/share/color-schemes/Nezuko.colors`

## ✅ Once installed, apply the theme via:
System Settings → Appearance

- Plasma Style: `Nezuko`

Global Theme: `Nezuko`

Icons: `Nezuko-Icons`

Cursors: `Nezuko-Cursors`

Color Scheme: `Nezuko`

##❌ Uninstallation
Make the unistaller excecutable
```bash
chmod +x uninstall.sh
```
```bash
./uninstall.sh
```
This will delete:
`~/.local/share/icons/Nezuko-Cursors`
`~/.local/share/icons/Nezuko-Icons`
`~/.local/share/plasma/desktoptheme/Nezuko`
`~/.local/share/plasma/look-and-feel/org.kde.nezuko`
`~/.local/share/color-schemes/Nezuko.colors`

## ⚠️ Troubleshooting

- If you see permission denied errors, make sure you cloned/extracted the theme as your user (not root).
Run:
```bash
chown -R $USER:$USER .
```
inside the theme folder before reinstalling.

- If the theme doesn’t show up in System Settings, try logging out/in or restarting Plasma with:
```bash
kquitapp6 plasmashell && kstart6 plasmashell
```
## 🪄 Credits

Made with ❤️ for KDE Plasma fans. Inspired by Nezuko Kamado.