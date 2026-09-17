#!/usr/bin/env bash
# ~/.config'deki güncel ayarları dotfiles reposuna kopyalar, commit'ler, mümkünse push'lar.
set -u
REPO="${DOTFILES:-$HOME/dev_space/dotfiles}"
C="$HOME/.config"
[ -d "$REPO/.git" ] || { echo "repo yok: $REPO"; exit 1; }

rsync -a --delete --exclude hyprpaper.conf --exclude wallpaper.conf --exclude __pycache__ "$C/hypr/" "$REPO/hypr/"
rsync -a --delete --exclude modules --exclude __pycache__ "$C/waybar/" "$REPO/waybar/"
mkdir -p "$REPO/waybar/modules"; cp "$C/waybar/modules/weather.sh" "$REPO/waybar/modules/" 2>/dev/null
cp "$C/rofi/config.rasi" "$REPO/rofi/"
cp "$C/ghostty/config"   "$REPO/ghostty/"
cp "$C/mako/config"      "$REPO/mako/"
cp "$C/autostart/blueman.desktop" "$REPO/autostart/"
mkdir -p "$REPO/xdg-desktop-portal"; cp "$C/xdg-desktop-portal/hyprland-portals.conf" "$REPO/xdg-desktop-portal/"
mkdir -p "$REPO/applications"; cp "$HOME/.local/share/applications/spotify.desktop" "$REPO/applications/" 2>/dev/null   # Spotify native Wayland

cd "$REPO" || exit 1
if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
    msg="No changes"; echo "$msg"
else
    git add -A
    git commit -q -m "Sync configs from ~/.config ($(date +%Y-%m-%d\ %H:%M))"
    msg="Commit: $(git log -1 --format=%h)"
    LOG="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-sync.log"
    # Anlık ağ hatalarına karşı bir kez daha dene; hatayı yutma, log'a yaz ve bildirimde göster
    if git push -q origin main 2>"$LOG" || { sleep 3; git push -q origin main 2>"$LOG"; }; then
        msg="$msg — pushed"
    else
        err=$(grep -v '^$' "$LOG" | tail -1)
        msg="$msg — push failed: ${err:-bilinmeyen hata} (log: $LOG)"
    fi
    echo "$msg"
fi
command -v notify-send >/dev/null && notify-send -a "Dotfiles" "$msg"
