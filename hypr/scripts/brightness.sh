#!/usr/bin/env bash
# Ekran parlaklığı tuşları + OSD bildirimi (volume.sh ile aynı biçim)
#   brightness.sh up | down
# Hızlı olsun diye: brightnessctl'nin -m çıktısı tek seferde okunur, python yok
set -u
osd() { notify-send -a Brightness -h string:x-canonical-private-synchronous:brightness -t 1200 -i "$1" "$2" "${3:-}" & }
bar() {   # bar <yüzde> → ▰▰▰▱▱ (100% = tam)
    local n=$(( ($1 * 15 + 50) / 100 )) s=""; [ $n -gt 15 ] && n=15
    for ((i = 0; i < 15; i++)); do [ $i -lt $n ] && s+="▰" || s+="▱"; done
    printf '%s' "$s"
}
case "${1:-}" in
    up)   out="$(brightnessctl -m -e4 -n2 set 5%+)" ;;
    down) out="$(brightnessctl -m -e4 -n2 set 5%-)" ;;
    *) echo "usage: $0 up|down"; exit 1 ;;
esac
# "intel_backlight,backlight,12000,50%,24000" → 50
IFS=, read -r _ _ _ pct _ <<< "$out"; pct="${pct%\%}"
# breeze: brightness-high / brightness-low (actions/22)
[ "$pct" -ge 40 ] && icon=brightness-high || icon=brightness-low
osd "$icon" "Brightness ${pct}%" "$(bar "$pct")"
