#!/usr/bin/env bash
# My Menu — quick access to your own scripts and the Hyprland tools.
# Add anything executable to ~/scripts (or ~/.local/bin/my-*) and it shows up here.
set -u
S="$HOME/.config/hypr/scripts"
USER_DIRS=("$HOME/scripts")

items() {
    printf '󰒓  Settings\t%s\n'        "$S/settings.sh"
    printf '󰸉  Wallpaper\t%s pick\n'   "$S/wallpaper.sh"
    printf '󰄀  Screenshot\t%s menu\n'  "$S/screenshot.sh"
    printf '󰓅  Power profile\t%s\n'   "$S/powerprofile.sh"
    printf '󰐥  Power menu\t%s\n'      "$S/powermenu.sh"
    printf '󰊢  Save dotfiles\t%s\n'   "$S/dotfiles-sync.sh"
    printf '󰈔  Edit this menu\t%s "%s"\n' "${EDITOR:-kate}" "$0"
    for d in "${USER_DIRS[@]}"; do
        [ -d "$d" ] || continue
        find "$d" -maxdepth 1 -type f -perm -u+x | sort | while read -r f; do
            printf '󰆍  %s\t%s\n' "$(basename "$f")" "$f"
        done
    done
    for f in "$HOME"/.local/bin/my-*; do [ -x "$f" ] && printf '󰆍  %s\t%s\n' "$(basename "$f")" "$f"; done
}

choice="$(items | rofi -dmenu -i -p "My Menu" -display-columns 1 -display-column-separator '\t' \
    -theme-str 'window { width: 380px; } listview { lines: 12; }')"
[ -z "$choice" ] && exit 0
cmd="${choice#*$'\t'}"
setsid bash -c "$cmd" >/dev/null 2>&1 &
