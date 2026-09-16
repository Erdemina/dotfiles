#!/usr/bin/env bash
# Güç profili — waybar pil modülüne tıklayınca (power-profiles-daemon)
#   powerprofile.sh        -> rofi menüsü
#   powerprofile.sh status -> waybar için mevcut profil (metin)
set -u
cur="$(powerprofilesctl get 2>/dev/null)"
label() { case "$1" in performance) echo "󰓅  Performance";; balanced) echo "󰾅  Balanced";; power-saver) echo "󰾆  Power saver";; esac; }
if [ "${1:-}" = status ]; then label "$cur"; exit 0; fi

choice="$(for p in performance balanced power-saver; do
    mark=" "; [ "$p" = "$cur" ] && mark=""
    printf '%s %s\n' "$(label "$p")" "$mark"
done | rofi -dmenu -i -p "Power profile ($(label "$cur" | sed 's/^[^ ]* *//'))" \
    -theme-str 'window { width: 300px; } listview { lines: 3; }')"
[ -z "$choice" ] && exit 0
case "$choice" in
    *Performance*) new=performance ;;
    *Balanced*)    new=balanced ;;
    *saver*)       new=power-saver ;;
esac
powerprofilesctl set "$new" && notify-send -a "Power" "Profile: $(label "$new")"
pkill -RTMIN+8 waybar 2>/dev/null   # pil modülünü tazele
