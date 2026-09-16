#!/usr/bin/env bash
# Güç profili — waybar pil modülüne tıklayınca (power-profiles-daemon)
#   powerprofile.sh        -> rofi menüsü
#   powerprofile.sh status -> waybar için mevcut profil (metin)
set -u
cur="$(powerprofilesctl get 2>/dev/null)"
label() { case "$1" in performance) echo "󰓅  Performans";; balanced) echo "󰾅  Dengeli";; power-saver) echo "󰾆  Güç tasarrufu";; esac; }
if [ "${1:-}" = status ]; then label "$cur"; exit 0; fi

choice="$(for p in performance balanced power-saver; do
    mark=" "; [ "$p" = "$cur" ] && mark=""
    printf '%s %s\n' "$(label "$p")" "$mark"
done | rofi -dmenu -i -p "Güç profili ($(label "$cur" | sed 's/^[^ ]* *//'))" \
    -theme-str 'window { width: 300px; } listview { lines: 3; }')"
[ -z "$choice" ] && exit 0
case "$choice" in
    *Performans*) new=performance ;;
    *Dengeli*)    new=balanced ;;
    *tasarruf*)   new=power-saver ;;
esac
powerprofilesctl set "$new" && notify-send -a "Güç" "Profil: $(label "$new")"
pkill -RTMIN+8 waybar 2>/dev/null   # pil modülünü tazele
