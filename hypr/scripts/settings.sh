#!/usr/bin/env bash
# Hyprland Ayarları — rofi menüsü (Meta+I)
# Config dosyalarını düzenler; Hyprland değişiklikleri otomatik yükler.
set -u
H="$HOME/.config/hypr"
S="$H/scripts"
EDITOR_CMD="${EDITOR:-kate}"
menu() { rofi -dmenu -i -p "$1" -theme-str 'window { width: 420px; } listview { lines: 14; }'; }
edit() { setsid "$EDITOR_CMD" "$@" >/dev/null 2>&1 & }
setlua() {   # setlua <dosya> <anahtar> <değer>   →  "anahtar = değer," satırını değiştirir
    sed -i -E "s|^(\s*$2\s*=\s*)[^,]*(,.*)?$|\1$3\2|" "$H/$1"
}
notify() { command -v notify-send >/dev/null && notify-send -a "Hyprland Ayarları" "$1" "${2:-}"; }

while :; do
choice="$(printf '%s\n' \
    "󰸉  Duvar kağıdı seç" \
    "󰏘  Kenarlık rengi" \
    "󰁌  Boşluklar (gaps)" \
    "󰂵  Blur aç/kapat" \
    "󰑮  Animasyon aç/kapat" \
    "󰌌  Klavye düzeni" \
    "󰍹  Monitör ayarı (dosya)" \
    "󰌌  Kısayolları göster" \
    "󰕾  Ses (pavucontrol)" \
    "󰤨  Ağ (nm-connection-editor)" \
    "󰂯  Bluetooth (blueman)" \
    "󰒓  KDE Sistem Ayarları (tema/imleç/font)" \
    "󰈔  Config dosyasını düzenle" \
    "󰑓  Config'i doğrula + yeniden yükle" \
    "󰊢  Dotfiles'a kaydet (git)" \
    | menu "Hyprland Ayarları")"
[ -z "$choice" ] && exit 0

case "$choice" in
    *"Duvar kağıdı"*) exec "$S/wallpaper.sh" pick ;;

    *"Kenarlık rengi"*)
        c="$(printf 'Mavi (89b4fa→74c7ec)\nTuruncu (ff492a→ffd72a)\nYeşil (a6e3a1→94e2d5)\nMor (cba6f7→f5c2e7)\nKırmızı (f38ba8→fab387)\nBeyaz (cdd6f4→bac2de)' | menu 'Kenarlık')"
        [ -z "$c" ] && continue
        a="${c#*(}"; a="${a%)*}"; c1="${a%→*}"; c2="${a#*→}"
        sed -i -E "s|(active_border\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(border_active\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(outer_color = rgba\()[0-9a-f]{6}|\1$c1|; s|(check_color = rgba\()[0-9a-f]{6}|\1$c2|" "$H/hyprlock.conf"
        sed -i -E "0,/border-color=#[0-9a-f]{6}/s|border-color=#[0-9a-f]{6}|border-color=#$c1|" "$HOME/.config/mako/config"
        sed -i -E "/#custom-power \{/,/\}/ s|color: #[0-9a-f]{6}|color: #$c1|" "$HOME/.config/waybar/style.css"
        sed -i -E "s|^(cursor-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(selection-foreground\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(split-divider-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|" "$HOME/.config/ghostty/config"
        makoctl reload 2>/dev/null; pkill -x waybar; setsid waybar >/dev/null 2>&1 &
        notify "Kenarlık rengi: $c" ;;

    *"Boşluklar"*)
        g="$(printf 'Sıkı (2 / 4)\nNormal (5 / 12)\nGeniş (8 / 20)\nYok (0 / 0)' | menu 'Boşluklar')"
        [ -z "$g" ] && continue
        a="${g#*(}"; a="${a%)*}"; gi="${a% / *}"; go="${a#* / }"
        setlua lookandfeel.lua gaps_in "$gi"; setlua lookandfeel.lua gaps_out "$go"
        notify "Boşluklar: iç $gi / dış $go" ;;

    *"Blur"*)
        cur="$(grep -oE 'blur\s*=\s*\{ enabled = (true|false)' "$H/lookandfeel.lua" | grep -oE 'true|false')"
        new=$([ "$cur" = true ] && echo false || echo true)
        sed -i -E "s|(blur\s*=\s*\{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Blur: $new" ;;

    *"Animasyon"*)
        cur="$(grep -oE 'animations = \{ enabled = (true|false)' "$H/lookandfeel.lua" | grep -oE 'true|false')"
        new=$([ "$cur" = true ] && echo false || echo true)
        sed -i -E "s|(animations = \{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Animasyon: $new" ;;

    *"Klavye"*)
        l="$(printf 'tr\nus\ntr,us\nde\ngb' | menu 'Klavye düzeni')"
        [ -z "$l" ] && continue
        sed -i -E "s|(kb_layout\s*=\s*)\"[a-z,]*\"|\1\"$l\"|" "$H/input.lua"
        notify "Klavye düzeni: $l" ;;

    *"Monitör"*) edit "$H/monitors.lua" ;;

    *"Kısayolları"*)
        hyprctl binds -j | python3 -c '
import json,sys
mods={1:"SHIFT",4:"CTRL",8:"ALT",64:"SUPER"}
for b in json.load(sys.stdin):
    m=b["modmask"]; ms=[n for k,n in mods.items() if m&k]
    key="+".join(ms+[b["key"] or "code:"+str(b["keycode"])])
    d=b.get("description") or (b["dispatcher"]+" "+b["arg"]).strip()
    print(f"{key:28} {d}")' | sort | rofi -dmenu -i -p "Kısayollar" -theme-str 'window { width: 720px; } listview { lines: 20; } element-text { font: "JetBrainsMono Nerd Font 10"; }' >/dev/null ;;

    *"Ses"*)       setsid pavucontrol >/dev/null 2>&1 & ;;
    *"Ağ"*)        setsid nm-connection-editor >/dev/null 2>&1 & ;;
    *"Bluetooth"*) setsid blueman-manager >/dev/null 2>&1 & ;;
    *"KDE Sistem"*) setsid systemsettings >/dev/null 2>&1 & ;;

    *"Config dosyasını"*)
        f="$(ls "$H"/*.lua "$H"/*.conf "$HOME/.config/waybar/config" "$HOME/.config/waybar/style.css" "$HOME/.config/ghostty/config" "$HOME/.config/mako/config" "$HOME/.config/rofi/config.rasi" 2>/dev/null | sed "s|$HOME/.config/||" | menu 'Dosya')"
        [ -n "$f" ] && edit "$HOME/.config/$f" ;;

    *"doğrula"*)
        out="$(Hyprland --verify-config 2>&1 | grep -v DEBUG | tail -5)"
        hyprctl reload >/dev/null; notify "Config" "$out" ;;

    *"Dotfiles"*) "$S/dotfiles-sync.sh" ;;
esac
exit 0
done
