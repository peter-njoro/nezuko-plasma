# 🌸 Nezuko Plasma Theme

A KDE Plasma theme inspired by Nezuko Kamado (Demon Slayer).  
Features:
- Frosted glass taskbar
- Pink Nezuko color scheme
- Custom icons (coming soon)
- Anime wallpaper
- Optional cursor theme

## 📦 Installation Guide

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/nezuko-plasma.git
cd nezuko-plasma
```
### 2. Install Plasma Theme

Copy the Plasma theme into your local Plasma themes directory:

```bash
mkdir -p ~/.local/share/plasma/desktoptheme/
cp -r plasma/Nezuko ~/.local/share/plasma/desktoptheme/
```
### 3. Install Icons
```bash
mkdir -p ~/.local/share/icons/
cp -r themes/Nezuko-Icons ~/.local/share/icons/
```
### Activate via:
```bash 
System Settings → Icons → Nezuko-Icons
```
### 4. Install Cursors
```bash
mkdir -p ~/.local/share/icons/
cp -r themes/Nezuko-Cursors ~/.local/share/icons/
```
### Activate via:
```System Settings → Cursors → Nezuko-Cursors```

### 5. Apply Plasma theme:
```bash
System Settings → Appearance → Global Theme → Nezuko
```
### 6. Restart and quit plasma shell
```bash
kquitapp5 plasmashell && kstart5 plasmashell
```

### 🧹 Uninstall
```bash
rm -rf ~/.local/share/plasma/desktoptheme/Nezuko
rm -rf ~/.local/share/icons/Nezuko-Icons
rm -rf ~/.local/share/icons/Nezuko-Cursors
```
