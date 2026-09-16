#!/usr/bin/env bash
# rofi güç menüsü
choice="$(printf '󰌾  Lock\n󰗽  Log out\n󰒲  Suspend\n󰜉  Reboot\n󰐥  Shut down' | rofi -dmenu -i -p 'Power' -theme-str 'listview { lines: 5; } window { width: 300px; }')"
case "$choice" in
    *Lock*)      hyprlock ;;
    *"Log out"*) hyprctl dispatch 'hl.dsp.exit()' ;;
    *Suspend*)   systemctl suspend ;;
    *Reboot*)    systemctl reboot ;;
    *"Shut down"*) systemctl poweroff ;;
esac
