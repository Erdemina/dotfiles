#!/usr/bin/env bash
# Volume / mic keys with sound + OSD notification (like KDE)
#   volume.sh up | down | mute | mic
# Hızlı olsun diye: tek wpctl sorgusu, python yok (tuşa basılı tutunca ~25 tekrar/sn geliyor)
set -u
SND=/usr/share/sounds/ocean/stereo/audio-volume-change.oga
osd() { notify-send -a Volume -h string:x-canonical-private-synchronous:volume -t 1200 -i "$1" "$2" "${3:-}" & }   # beklemeden devam
bar() {   # bar <yüzde> → ▰▰▰▱▱ (150% = tam)
    local n=$(( ($1 * 15 + 75) / 150 )) s=""; [ $n -gt 15 ] && n=15
    for ((i = 0; i < 15; i++)); do [ $i -lt $n ] && s+="▰" || s+="▱"; done
    printf '%s' "$s"
}
case "${1:-}" in
    up)   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic)  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
          case "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)" in
              *MUTED*) osd microphone-sensitivity-muted "Microphone muted" ;;
              *)       osd microphone-sensitivity-high  "Microphone on" ;;
          esac
          exit 0 ;;
    *) echo "usage: $0 up|down|mute|mic"; exit 1 ;;
esac
# "Volume: 0.45 [MUTED]" → tek sorguda hem seviye hem mute
read -r _ level state < <(wpctl get-volume @DEFAULT_AUDIO_SINK@)
if [ "${state:-}" = "[MUTED]" ]; then
    osd audio-volume-muted "Muted"
else
    v="${level/./}"; v=$((10#$v))                      # 0.45 → 45, 1.20 → 120
    icon=audio-volume-high; [ "$v" -lt 66 ] && icon=audio-volume-medium; [ "$v" -lt 33 ] && icon=audio-volume-low
    osd "$icon" "Volume" "$(bar "$v")  $v%"
    [ -f "$SND" ] && pw-play "$SND" >/dev/null 2>&1 &
fi
