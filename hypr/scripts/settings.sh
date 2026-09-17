#!/usr/bin/env bash
# Hyprland Settings — rofi menu (Meta+I)
# Edits config files; Hyprland reloads changes automatically.
# Menü bir ayar değiştirince kapanmaz: alt menüde "Back"/Esc ana menüye döner,
# ana menüde "Close"/Esc kapatır. Sadece harici uygulama açan maddeler menüyü kapatır.
set -u
H="$HOME/.config/hypr"
S="$H/scripts"
WB="$HOME/.config/waybar"
EDITOR_CMD="${EDITOR:-kate}"
BACK="󰌍  Back"
menu() { rofi -dmenu -i -p "$1" -selected-row "${2:-0}" -theme-str 'window { width: 420px; } listview { lines: 15; }'; }
submenu() { { echo "$BACK"; cat; } | menu "$1" 1; }       # boş / Back → çağıran `continue` yapar
back() { [ -z "$1" ] || [ "$1" = "$BACK" ]; }
edit() { setsid "$EDITOR_CMD" "$@" >/dev/null 2>&1 & }
setlua() {   # setlua <file> <key> <value>  → rewrites "key = value," line
    sed -i -E "s|^(\s*$2\s*=\s*)[^,]*(,.*)?$|\1$3\2|" "$H/$1"
}
luaflag() { grep -oE "$1\s*=\s*\{ enabled = (true|false)" "$H/lookandfeel.lua" | grep -oE 'true|false'; }
onoff() { [ "$1" = true ] && echo on || echo off; }
notify() { command -v notify-send >/dev/null && notify-send -a "Hyprland Settings" "$1" "${2:-}"; }
restart_waybar() { pkill -x waybar; pkill -f "$WB/mediaplayer.py"; setsid waybar >/dev/null 2>&1 & }
waybar_font() { grep -m1 -oE 'font-size: [0-9]+px' "$WB/style.css" | grep -oE '[0-9]+'; }

row=0
while :; do
items=(
    "󰸉  Wallpaper"
    "󰏘  Border colour"
    "󰁌  Gaps"
    "󰍜  Waybar size ($(waybar_font)px)"
    "󰂵  Blur: $(onoff "$(luaflag blur)")"
    "󰑮  Animations: $(onoff "$(luaflag animations)")"
    "󰌌  Keyboard layout"
    "󰓅  Power profile"
    "󰍹  Monitors (edit file)"
    "󰌌  Show keybindings"
    "󰕾  Audio (pavucontrol)"
    "󰤨  Network (nm-connection-editor)"
    "󰂯  Bluetooth (blueman)"
    "󰒓  KDE System Settings (theme / cursor / fonts)"
    "󰈔  Edit a config file"
    "󰑓  Verify + reload config"
    "󰊢  Save to dotfiles (git)"
    "󰅖  Close"
)
choice="$(printf '%s\n' "${items[@]}" | menu "Hyprland Settings" "$row")"
[ -z "$choice" ] && exit 0
for i in "${!items[@]}"; do [ "${items[$i]}" = "$choice" ] && row=$i; done   # dönünce aynı satır seçili kalsın

case "$choice" in
    *Close*) exit 0 ;;
    *Wallpaper*) "$S/wallpaper.sh" pick ;;

    *"Border colour"*)
        c="$(printf 'Blue (89b4fa→74c7ec)\nOrange (ff492a→ffd72a)\nGreen (a6e3a1→94e2d5)\nPurple (cba6f7→f5c2e7)\nRed (f38ba8→fab387)\nWhite (cdd6f4→bac2de)' | submenu 'Border colour')"
        back "$c" && continue
        a="${c#*(}"; a="${a%)*}"; c1="${a%→*}"; c2="${a#*→}"
        sed -i -E "s|(active_border\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(border_active\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(outer_color = rgba\()[0-9a-f]{6}|\1$c1|; s|(check_color = rgba\()[0-9a-f]{6}|\1$c2|" "$H/hyprlock.conf"
        sed -i -E "0,/border-color=#[0-9a-f]{6}/s|border-color=#[0-9a-f]{6}|border-color=#$c1|" "$HOME/.config/mako/config"
        sed -i -E "/#custom-power \{/,/\}/ s|^(\\s*)color: #[0-9a-f]{6}|\\1color: #$c1|" "$WB/style.css"
        sed -i -E "s|^(cursor-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(selection-foreground\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(split-divider-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|" "$HOME/.config/ghostty/config"
        sed -i -E "s|^(\s*w-border-color:\s*)#[0-9a-fA-F]{6}|\1#$c1|; s|^(\s*hl-color:\s*)#[0-9a-fA-F]{6}|\1#$c1|" "$HOME/.config/rofi/config.rasi"
        makoctl reload 2>/dev/null; restart_waybar
        notify "Border colour: $c" ;;

    *Gaps*)
        g="$(printf 'Tight (2 / 4)\nNormal (5 / 12)\nWide (8 / 20)\nNone (0 / 0)' | submenu 'Gaps (inner / outer)')"
        back "$g" && continue
        a="${g#*(}"; a="${a%)*}"; gi="${a% / *}"; go="${a#* / }"
        setlua lookandfeel.lua gaps_in "$gi"; setlua lookandfeel.lua gaps_out "$go"
        notify "Gaps: inner $gi / outer $go" ;;

    *"Waybar size"*)
        cur="$(waybar_font)"
        w="$(for o in 'Small (10px)' 'Normal (11px)' 'Large (13px)' 'Extra large (15px)' 'Huge (18px)'; do
                 [ "${o#*(}" = "${cur}px)" ] && o="$o  "; echo "$o"; done | submenu 'Waybar size')"
        back "$w" && continue
        f="${w#*(}"; f="${f%px)*}"
        sed -i -E "0,/font-size: [0-9]+px;/s//font-size: ${f}px;/" "$WB/style.css"                          # genel yazı (* kuralı)
        sed -i -E "/#custom-workspaces \{/,/\}/ s/font-size: [0-9]+px/font-size: $((f + 1))px/" "$WB/style.css"
        sed -i -E "s/(\"icon-size\": )[0-9]+/\1$((f + 4))/" "$WB/config"                                       # tray ikonları
        restart_waybar
        notify "Waybar size: ${f}px" ;;

    *Blur*)
        new=$([ "$(luaflag blur)" = true ] && echo false || echo true)
        sed -i -E "s|(blur\s*=\s*\{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Blur: $(onoff "$new")" ;;

    *Animations*)
        new=$([ "$(luaflag animations)" = true ] && echo false || echo true)
        sed -i -E "s|(animations = \{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Animations: $(onoff "$new")" ;;

    *Keyboard*)
        l="$(printf 'tr\nus\ntr,us\nde\ngb' | submenu 'Keyboard layout')"
        back "$l" && continue
        sed -i -E "s|(kb_layout\s*=\s*)\"[a-z,]*\"|\1\"$l\"|" "$H/input.lua"
        notify "Keyboard layout: $l" ;;

    *"Power profile"*) "$S/powerprofile.sh" ;;
    *Monitors*) edit "$H/monitors.lua"; exit 0 ;;

    *keybindings*)
        hyprctl binds -j | python3 -c '
import json,sys
mods={1:"SHIFT",4:"CTRL",8:"ALT",64:"SUPER"}
for b in json.load(sys.stdin):
    m=b["modmask"]; ms=[n for k,n in mods.items() if m&k]
    key="+".join(ms+[b["key"] or "code:"+str(b["keycode"])])
    d=b.get("description") or (b["dispatcher"]+" "+b["arg"]).strip()
    print(f"{key:28} {d}")' | sort | rofi -dmenu -i -p "Keybindings" -theme-str 'window { width: 720px; } listview { lines: 20; } element-text { font: "JetBrainsMono Nerd Font 10"; }' >/dev/null ;;

    # Harici uygulama açanlar: rofi'nin arkasında kalmasın diye menü kapanır
    *Audio*)     setsid pavucontrol >/dev/null 2>&1 & exit 0 ;;
    *Network*)   setsid nm-connection-editor >/dev/null 2>&1 & exit 0 ;;
    *Bluetooth*) setsid blueman-manager >/dev/null 2>&1 & exit 0 ;;
    *"KDE System"*) setsid systemsettings >/dev/null 2>&1 & exit 0 ;;

    *"Edit a config"*)
        f="$(ls "$H"/*.lua "$H"/*.conf "$WB/config" "$WB/style.css" "$HOME/.config/ghostty/config" "$HOME/.config/mako/config" "$HOME/.config/rofi/config.rasi" 2>/dev/null | sed "s|$HOME/.config/||" | submenu 'File')"
        back "$f" && continue
        edit "$HOME/.config/$f"; exit 0 ;;

    *Verify*)
        out="$(Hyprland --verify-config 2>&1 | grep -v DEBUG | tail -5)"
        hyprctl reload >/dev/null; notify "Config" "$out" ;;

    *dotfiles*) "$S/dotfiles-sync.sh" ;;
esac
done
