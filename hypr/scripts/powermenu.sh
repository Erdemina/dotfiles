#!/usr/bin/env bash
# rofi güç menüsü
choice="$(printf '󰌾  Kilitle\n󰗽  Oturumu kapat\n󰒲  Uyku\n󰜉  Yeniden başlat\n󰐥  Kapat' | rofi -dmenu -i -p 'Güç' -theme-str 'listview { lines: 5; } window { width: 300px; }')"
case "$choice" in
    *Kilitle*)          hyprlock ;;
    *"Oturumu kapat"*)  hyprctl dispatch 'hl.dsp.exit()' ;;
    *Uyku*)             systemctl suspend ;;
    *"Yeniden başlat"*) systemctl reboot ;;
    *Kapat*)            systemctl poweroff ;;
esac
