#!/usr/bin/env bash
set -e

echo "=== KDE Rice installer for EndeavourOS / Arch ==="

# --- Sanity checks ---------------------------------------------------------

if ! command -v pacman >/dev/null 2>&1; then
  echo "This script is for Arch-based distros (pacman not found). Aborting."
  exit 1
fi

# paru is the easiest way to pull AUR stuff if you want to later
if ! command -v paru >/dev/null 2>&1; then
  echo "paru not found."
  echo "If you want automated AUR installs (Sweet-KDE, etc.), install paru first:"
  echo "  sudo pacman -S --needed base-devel git"
  echo "  git clone https://aur.archlinux.org/paru.git"
  echo "  cd paru && makepkg -si"
  echo
  echo "For now I'll continue with repo-only packages."
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Core packages ---------------------------------------------------------

echo
echo ">>> Installing required packages (repo)..."
sudo pacman -S --needed --noconfirm \
  kvantum-qt5 kvantum-qt6 \
  papirus-icon-theme \
  kdeplasma-addons \
  conky \
  ttf-ubuntu-font-family \
  ttf-fantasque-sans-mono \
  git

echo
echo ">>> (Optional) You should install the following via KDE Store / Get New Stuff:"
echo "  - Breeze AlphaBlack (Plasma Theme)"
echo "  - Sweet KDE / Sweet-Mars (Plasma + Kvantum + Aurorae) by EliverLara"
echo "  - SpaceK Cursors"
echo
echo "Open System Settings → Appearance → each section → 'Get New...' and search:"
echo "  * \"Breeze AlphaBlack\""
echo "  * \"Sweet KDE\" or \"Sweet Mars\""
echo "  * \"SpaceK\" cursors"
echo

# --- Wallpaper -------------------------------------------------------------

WALL_DIR="$HOME/.local/share/wallpapers"
mkdir -p "$WALL_DIR"

if [ -f "$ROOT_DIR/wallpapers/WEKKBhB.png" ]; then
  echo ">>> Installing wallpaper from repo..."
  cp "$ROOT_DIR/wallpapers/WEKKBhB.png" "$WALL_DIR/plasma-rice-wallpaper.png"
else
  echo ">>> Downloading wallpaper from imgur..."
  curl -L "https://i.imgur.com/WEKKBhB.png" -o "$WALL_DIR/plasma-rice-wallpaper.png"
fi

echo "Wallpaper installed at: $WALL_DIR/plasma-rice-wallpaper.png"
echo "Set it in: Desktop Right-Click → Configure Desktop → Wallpaper."

# --- Conky -----------------------------------------------------------------

echo
echo ">>> Installing Conky config..."
mkdir -p "$HOME/.config/conky"
cp "$ROOT_DIR/conky/conky.conf" "$HOME/.config/conky/conky.conf"

echo "You can start it with:  conky -c ~/.config/conky/conky.conf"
echo "To autostart, add a script or .desktop in ~/.config/autostart."

# --- SimpleFox (Firefox) ---------------------------------------------------

echo
echo ">>> Installing SimpleFox (Firefox userChrome) in your default profile..."

# Try to guess default Firefox profile directory
FF_BASE="$HOME/.mozilla/firefox"
FF_PROFILE=""
if [ -d "$FF_BASE" ]; then
  # pick first *.default* profile
  FF_PROFILE=$(find "$FF_BASE" -maxdepth 1 -type d -name "*.default*" | head -n 1 || true)
fi

if [ -z "$FF_PROFILE" ]; then
  echo "Could not auto-detect Firefox profile."
  echo "Install SimpleFox manually from:"
  echo "  https://github.com/migueravila/SimplerentFox"
else
  echo "Detected Firefox profile: $FF_PROFILE"
  TMP_DIR="$(mktemp -d)"
  git clone --depth 1 "https://github.com/migueravila/SimplerentFox.git" "$TMP_DIR"
  # The repo ships a 'chrome' folder; copy it directly
  mkdir -p "$FF_PROFILE/chrome"
  cp -r "$TMP_DIR/chrome/"* "$FF_PROFILE/chrome/"
  rm -rf "$TMP_DIR"

  echo
  echo "SimpleFox files installed to: $FF_PROFILE/chrome"
  echo "Now open about:config in Firefox and set:"
  echo "  toolkit.legacyUserProfileCustomizations.stylesheets = true"
  echo "  (optional performance flags as per repo README)"
fi

# --- Final instructions ----------------------------------------------------

cat << 'EOF'

============================================================
Almost done!

Now apply everything manually in Plasma:

1) Plasma Style:
   System Settings → Appearance → Plasma Style → Breeze AlphaBlack

2) Application Style (Kvantum):
   • Open Kvantum Manager
   • Choose Sweet-Mars (or Sweet-Mars-transparent-toolbar)
   • Apply to all Qt apps
   (Install Sweet KDE / Sweet Mars from:
      - KDE Store: "Sweet Mars KDE"
      - or GitHub: https://github.com/EliverLara/Sweet-kde )

3) Window Decorations:
   System Settings → Appearance → Window Decorations → Sweet-Mars

4) Colors:
   System Settings → Appearance → Colors → Sweet-Mars

5) Icons:
   System Settings → Icons → Papirus Dark → Red variant

6) Cursors:
   System Settings → Cursors → SpaceK

7) Fonts:
   System Settings → Fonts:
     - General: Ubuntu
     - Fixed-width: Fantasque Sans Mono
     - Toolbar/Menu/Small: Ubuntu

8) Panel (Option B – clean version):
   - Right click panel → Edit Panel
   - Left: Application Launcher
   - Center: Digital Clock (or Event Calendar with inline clock)
   - Right side widgets:
       • System Tray
       • Thermal Monitor
       • System Load Viewer
       • Virtual Desktop Bar
   - Tune spacing via "More Options" → Panel Height / Icon size

9) Conky:
   Test:  conky -c ~/.config/conky/conky.conf
   If it appears on the wrong monitor, edit:
     xinerama_head = 2,
   in conky.conf and change to 0 or 1.

Enjoy your EndeavourOS KDE rice :)
============================================================

EOF
