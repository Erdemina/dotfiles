#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────
#  Hyprland alongside KDE Plasma — installer for CachyOS / Arch
#  KDE Plasma'nın yanına Hyprland — CachyOS / Arch kurulum betiği
#
#  Usage / Kullanım:
#    ./install.sh              install packages + copy configs
#    ./install.sh --link       symlink configs into ~/.config (repo stays the source)
#    ./install.sh --no-pkgs    skip pacman step
#    ./install.sh --dry-run    only show what would happen
# ──────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
TS="$(date +%Y%m%d-%H%M%S)"
LINK=0; PKGS=1; DRY=0
for a in "$@"; do
    case "$a" in
        --link) LINK=1 ;;
        --no-pkgs) PKGS=0 ;;
        --dry-run) DRY=1 ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "unknown option: $a"; exit 1 ;;
    esac
done

c()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m ✓ \033[0m %s\n' "$*"; }
w()  { printf '\033[1;33m ! \033[0m %s\n' "$*"; }
run(){ if [ "$DRY" = 1 ]; then echo "   [dry] $*"; else "$@"; fi; }

# ── 0. sanity ────────────────────────────────────────────────────────────
[ "$(id -u)" = 0 ] && { echo "Run as your normal user, not root."; exit 1; }
command -v pacman >/dev/null || { echo "pacman not found — this script targets CachyOS / Arch."; exit 1; }
if ! pacman -Q plasma-desktop >/dev/null 2>&1; then
    w "KDE Plasma not detected. The setup still works, but wallpaper sync and KDE apps (Spectacle, Dolphin, polkit-kde) assume Plasma is installed."
fi

# ── 1. packages ──────────────────────────────────────────────────────────
PACKAGES=(
    # compositor + hypr ecosystem
    hyprland xdg-desktop-portal-hyprland hyprpaper hyprlock hypridle hyprshot hyprland-guiutils
    # bar / launcher / notifications / clipboard
    waybar rofi mako cliphist wl-clipboard grim slurp
    # terminal + tray helpers
    ghostty network-manager-applet blueman brightnessctl playerctl pavucontrol btop xsensors
    # KDE apps reused inside Hyprland
    spectacle dolphin konsole polkit-kde-agent kde-cli-tools plasma-integration capitaine-cursors
    # fonts + python for waybar media module
    ttf-jetbrains-mono-nerd otf-font-awesome noto-fonts noto-fonts-emoji python-gobject
)
if [ "$PKGS" = 1 ]; then
    c "Installing packages (sudo)"
    run sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
    ok "packages"
else
    w "skipping package install (--no-pkgs)"
fi

# ── 2. deploy configs ────────────────────────────────────────────────────
deploy() {   # deploy <repo-subdir> <target-dir>
    local src="$REPO/$1" dst="$2"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        run mv "$dst" "$dst.bak-$TS"
        w "existing $dst → $dst.bak-$TS"
    fi
    run mkdir -p "$(dirname "$dst")"
    if [ "$LINK" = 1 ]; then run ln -s "$src" "$dst"; else run cp -r "$src" "$dst"; fi
    ok "$dst"
}
c "Deploying configs to $CFG"
deploy hypr    "$CFG/hypr"
deploy waybar  "$CFG/waybar"
deploy rofi    "$CFG/rofi"
deploy ghostty "$CFG/ghostty"
deploy mako    "$CFG/mako"
run mkdir -p "$CFG/autostart"
run cp "$REPO/autostart/blueman.desktop" "$CFG/autostart/blueman.desktop"   # keep blueman out of the KDE session
ok "$CFG/autostart/blueman.desktop"
run mkdir -p "$CFG/xdg-desktop-portal"
run cp "$REPO/xdg-desktop-portal/hyprland-portals.conf" "$CFG/xdg-desktop-portal/"   # Secret portal → KWallet (Chromium logins survive)
ok "$CFG/xdg-desktop-portal/hyprland-portals.conf"
run chmod +x "$CFG/hypr/scripts/"*.sh "$CFG/waybar/mediaplayer.py" "$CFG/waybar/modules/"*.sh 2>/dev/null || true

# ── 3. keyboard layout from the system (localectl) ───────────────────────
LAYOUT="$(localectl status 2>/dev/null | awk -F': ' '/X11 Layout/ {print $2}')"
if [ -n "$LAYOUT" ] && [ "$DRY" = 0 ]; then
    sed -i "s/kb_layout  = \"[a-z,]*\"/kb_layout  = \"$LAYOUT\"/" "$CFG/hypr/input.lua"
    ok "keyboard layout: $LAYOUT"
fi

# ── 4. initial wallpaper from KDE ────────────────────────────────────────
if [ "$DRY" = 0 ]; then
    IMG="$("$CFG/hypr/scripts/wallpaper.sh" current)"
    printf 'splash = false\npreload = %s\nwallpaper = ,%s\n' "$IMG" "$IMG" > "$CFG/hypr/hyprpaper.conf"
    printf '$wallpaper = %s\n' "$IMG" > "$CFG/hypr/wallpaper.conf"
    ok "wallpaper: $IMG"
fi

# ── 5. verify ────────────────────────────────────────────────────────────
if [ "$DRY" = 0 ] && command -v Hyprland >/dev/null; then
    c "Verifying Hyprland config"
    if HYPRLAND_CONFIG="$CFG/hypr/hyprland.lua" Hyprland --verify-config 2>&1 | grep -q '^config ok'; then ok "config ok"; else
        HYPRLAND_CONFIG="$CFG/hypr/hyprland.lua" Hyprland --verify-config 2>&1 | grep -v DEBUG; w "config has errors — see above"; fi
fi

cat <<MSG

Done. Reboot (or log out) and pick "Hyprland" in the session menu — KDE stays untouched.
Bitti. Yeniden başlatıp giriş ekranında "Hyprland" oturumunu seçin — KDE olduğu gibi kalır.

  Meta+I  settings menu         Meta+Shift+B wallpaper picker   Meta+Q        terminal (ghostty)
  Meta    launcher (rofi)
  Meta+C  close window          Meta+F      fullscreen          Meta+M        power menu
  Print   Spectacle             Meta+L      lock (hyprlock)     Meta+V        clipboard history
MSG
