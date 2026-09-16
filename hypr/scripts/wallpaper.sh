#!/usr/bin/env bash
# KDE <-> Hyprland ortak duvar kağıdı.
# Tek kaynak: KDE'nin plasma-org.kde.plasma.desktop-appletsrc dosyası.
#   wallpaper.sh current      -> KDE masaüstü duvar kağıdı yolunu yazdırır
#   wallpaper.sh apply        -> KDE'deki duvar kağıdını hyprpaper'a uygular (Hyprland açılışında)
#   wallpaper.sh set <dosya>  -> hem KDE (masaüstü + kilit ekranı) hem Hyprland'e uygular
#   wallpaper.sh pick         -> rofi ile seçtir, sonra set
set -u
APPLETSRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
LOCKRC="$HOME/.config/kscreenlockerrc"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
FALLBACK="/usr/share/wallpapers/cachyos-wallpapers/north.png"
WALL_DIRS=("$HOME/Pictures/Wallpapers" "/usr/share/wallpapers/cachyos-wallpapers")

# Küçük INI okuyucu: kconfig'in iç içe [A][B][C] grup başlıklarını tek anahtar olarak tutar
kcfg() {
    python3 - "$@" <<'PY'
import re, sys, os
mode, path = sys.argv[1], sys.argv[2]
data, sec = {}, None
try:
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if line.startswith("["):
            sec = line; data.setdefault(sec, {})
        elif "=" in line and sec is not None:
            k, v = line.split("=", 1); data[sec][k] = v
except FileNotFoundError:
    pass
# activityId dolu containment'lar masaüstüdür (paneller boş)
desk = []
for sec, kv in data.items():
    m = re.fullmatch(r"\[Containments\]\[(\d+)\]", sec)
    if m and kv.get("activityId"):
        desk.append((int(kv.get("lastScreen", "99")), m.group(1)))
desk.sort()
if mode == "ids":
    for _, cid in desk: print(cid)
elif mode == "desktop-image":
    for _, cid in desk:
        img = data.get(f"[Containments][{cid}][Wallpaper][org.kde.image][General]", {}).get("Image", "")
        img = re.sub(r"^file://", "", img)
        if img and os.path.exists(img):
            print(img); break
elif mode == "lock-image":
    img = re.sub(r"^file://", "", data.get("[Greeter][Wallpaper][org.kde.image][General]", {}).get("Image", ""))
    if img and os.path.exists(img): print(img)
PY
}

current() {
    local img
    img="$(kcfg desktop-image "$APPLETSRC")"
    [ -z "$img" ] && img="$(kcfg lock-image "$LOCKRC")"
    [ -z "$img" ] && img="$FALLBACK"
    echo "$img"
}

write_hyprpaper_conf() {
    # hyprpaper >= 0.8 formatı
    printf 'splash = false\n\nwallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n' "$1" > "$HYPRPAPER_CONF"
    printf '$wallpaper = %s\n' "$1" > "$HOME/.config/hypr/wallpaper.conf"   # hyprlock için
}

apply_hypr() {
    local img="$1"
    write_hyprpaper_conf "$img"
    if pgrep -x hyprpaper >/dev/null; then
        # hyprpaper >= 0.8 IPC: her monitöre ayrı ayrı ver (fallback yalnız yeni monitörlere uygulanır)
        for mon in $(hyprctl monitors -j | python3 -c 'import json,sys; print(" ".join(m["name"] for m in json.load(sys.stdin)))'); do
            hyprctl hyprpaper wallpaper "$mon, $img, cover" >/dev/null
        done
    else
        setsid hyprpaper >/dev/null 2>&1 &
    fi
}

apply_kde() {
    local img="$1" cid
    if pgrep -x plasmashell >/dev/null; then
        plasma-apply-wallpaperimage "$img" >/dev/null 2>&1
    else
        # Plasma çalışmıyor: dosyaya doğrudan yaz
        for cid in $(kcfg ids "$APPLETSRC"); do
            kwriteconfig6 --file "$APPLETSRC" --group Containments --group "$cid" \
                --group Wallpaper --group org.kde.image --group General --key Image "$img"
            kwriteconfig6 --file "$APPLETSRC" --group Containments --group "$cid" \
                --group Wallpaper --group org.kde.image --group General --key PreviewImage "$img"
        done
    fi
    # Kilit ekranı
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$img"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$img"
}

case "${1:-}" in
    current) current ;;
    apply)   apply_hypr "$(current)" ;;
    set)
        img="$(realpath -e "${2:?dosya gerekli}")" || exit 1
        apply_kde "$img"
        if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then apply_hypr "$img"; fi
        ;;
    pick)
        choice="$(for d in "${WALL_DIRS[@]}"; do [ -d "$d" ] && find "$d" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) ; done \
            | sort | while read -r f; do printf '%s\0icon\x1f%s\n' "$f" "$f"; done \
            | rofi -dmenu -i -p "Duvar kağıdı" -show-icons)"
        [ -n "$choice" ] && exec "$0" set "$choice"
        ;;
    *) echo "kullanım: $0 current|apply|set <dosya>|pick"; exit 1 ;;
esac
