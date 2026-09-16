#!/usr/bin/env bash
# Hyprland Settings — rofi menu (Meta+I)
# Edits config files; Hyprland reloads changes automatically.
set -u
H="$HOME/.config/hypr"
S="$H/scripts"
EDITOR_CMD="${EDITOR:-kate}"
menu() { rofi -dmenu -i -p "$1" -theme-str 'window { width: 420px; } listview { lines: 15; }'; }
edit() { setsid "$EDITOR_CMD" "$@" >/dev/null 2>&1 & }
setlua() {   # setlua <file> <key> <value>  → rewrites "key = value," line
    sed -i -E "s|^(\s*$2\s*=\s*)[^,]*(,.*)?$|\1$3\2|" "$H/$1"
}
notify() { command -v notify-send >/dev/null && notify-send -a "Hyprland Settings" "$1" "${2:-}"; }
restart_waybar() { pkill -x waybar; setsid waybar >/dev/null 2>&1 & }

while :; do
choice="$(printf '%s\n' \
    "󰸉  Wallpaper" \
    "󰏘  Border colour" \
    "󰁌  Gaps" \
    "󰂵  Blur on/off" \
    "󰑮  Animations on/off" \
    "󰌌  Keyboard layout" \
    "󰓅  Power profile" \
    "󰍹  Monitors (edit file)" \
    "󰌌  Show keybindings" \
    "󰕾  Audio (pavucontrol)" \
    "󰤨  Network (nm-connection-editor)" \
    "󰂯  Bluetooth (blueman)" \
    "󰒓  KDE System Settings (theme / cursor / fonts)" \
    "󰈔  Edit a config file" \
    "󰑓  Verify + reload config" \
    "󰊢  Save to dotfiles (git)" \
    | menu "Hyprland Settings")"
[ -z "$choice" ] && exit 0

case "$choice" in
    *Wallpaper*) exec "$S/wallpaper.sh" pick ;;

    *"Border colour"*)
        c="$(printf 'Blue (89b4fa→74c7ec)\nOrange (ff492a→ffd72a)\nGreen (a6e3a1→94e2d5)\nPurple (cba6f7→f5c2e7)\nRed (f38ba8→fab387)\nWhite (cdd6f4→bac2de)' | menu 'Border colour')"
        [ -z "$c" ] && continue
        a="${c#*(}"; a="${a%)*}"; c1="${a%→*}"; c2="${a#*→}"
        sed -i -E "s|(active_border\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(border_active\s*=\s*\{ colors = \{ \"rgba\()[0-9a-f]{6}(ee\)\", \"rgba\()[0-9a-f]{6}|\1$c1\2$c2|" "$H/lookandfeel.lua"
        sed -i -E "s|(outer_color = rgba\()[0-9a-f]{6}|\1$c1|; s|(check_color = rgba\()[0-9a-f]{6}|\1$c2|" "$H/hyprlock.conf"
        sed -i -E "0,/border-color=#[0-9a-f]{6}/s|border-color=#[0-9a-f]{6}|border-color=#$c1|" "$HOME/.config/mako/config"
        sed -i -E "/#custom-power \{/,/\}/ s|color: #[0-9a-f]{6}|color: #$c1|" "$HOME/.config/waybar/style.css"
        sed -i -E "s|^(cursor-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(selection-foreground\s*=\s*)#[0-9a-f]{6}|\1#$c1|; s|^(split-divider-color\s*=\s*)#[0-9a-f]{6}|\1#$c1|" "$HOME/.config/ghostty/config"
        makoctl reload 2>/dev/null; restart_waybar
        notify "Border colour: $c" ;;

    *Gaps*)
        g="$(printf 'Tight (2 / 4)\nNormal (5 / 12)\nWide (8 / 20)\nNone (0 / 0)' | menu 'Gaps (inner / outer)')"
        [ -z "$g" ] && continue
        a="${g#*(}"; a="${a%)*}"; gi="${a% / *}"; go="${a#* / }"
        setlua lookandfeel.lua gaps_in "$gi"; setlua lookandfeel.lua gaps_out "$go"
        notify "Gaps: inner $gi / outer $go" ;;

    *Blur*)
        cur="$(grep -oE 'blur\s*=\s*\{ enabled = (true|false)' "$H/lookandfeel.lua" | grep -oE 'true|false')"
        new=$([ "$cur" = true ] && echo false || echo true)
        sed -i -E "s|(blur\s*=\s*\{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Blur: $new" ;;

    *Animations*)
        cur="$(grep -oE 'animations = \{ enabled = (true|false)' "$H/lookandfeel.lua" | grep -oE 'true|false')"
        new=$([ "$cur" = true ] && echo false || echo true)
        sed -i -E "s|(animations = \{ enabled = )(true\|false)|\1$new|" "$H/lookandfeel.lua"
        notify "Animations: $new" ;;

    *Keyboard*)
        l="$(printf 'tr\nus\ntr,us\nde\ngb' | menu 'Keyboard layout')"
        [ -z "$l" ] && continue
        sed -i -E "s|(kb_layout\s*=\s*)\"[a-z,]*\"|\1\"$l\"|" "$H/input.lua"
        notify "Keyboard layout: $l" ;;

    *"Power profile"*) exec "$S/powerprofile.sh" ;;
    *Monitors*) edit "$H/monitors.lua" ;;

    *keybindings*)
        hyprctl binds -j | python3 -c '
import json,sys
mods={1:"SHIFT",4:"CTRL",8:"ALT",64:"SUPER"}
for b in json.load(sys.stdin):
    m=b["modmask"]; ms=[n for k,n in mods.items() if m&k]
    key="+".join(ms+[b["key"] or "code:"+str(b["keycode"])])
    d=b.get("description") or (b["dispatcher"]+" "+b["arg"]).strip()
    print(f"{key:28} {d}")' | sort | rofi -dmenu -i -p "Keybindings" -theme-str 'window { width: 720px; } listview { lines: 20; } element-text { font: "JetBrainsMono Nerd Font 10"; }' >/dev/null ;;

    *Audio*)     setsid pavucontrol >/dev/null 2>&1 & ;;
    *Network*)   setsid nm-connection-editor >/dev/null 2>&1 & ;;
    *Bluetooth*) setsid blueman-manager >/dev/null 2>&1 & ;;
    *"KDE System"*) setsid systemsettings >/dev/null 2>&1 & ;;

    *"Edit a config"*)
        f="$(ls "$H"/*.lua "$H"/*.conf "$HOME/.config/waybar/config" "$HOME/.config/waybar/style.css" "$HOME/.config/ghostty/config" "$HOME/.config/mako/config" "$HOME/.config/rofi/config.rasi" 2>/dev/null | sed "s|$HOME/.config/||" | menu 'File')"
        [ -n "$f" ] && edit "$HOME/.config/$f" ;;

    *Verify*)
        out="$(Hyprland --verify-config 2>&1 | grep -v DEBUG | tail -5)"
        hyprctl reload >/dev/null; notify "Config" "$out" ;;

    *dotfiles*) "$S/dotfiles-sync.sh" ;;
esac
exit 0
done
