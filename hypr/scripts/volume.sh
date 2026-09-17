#!/usr/bin/env bash
# Volume / mic keys with sound + OSD notification (like KDE)
#   volume.sh up | down | mute | mic
set -u
SND=/usr/share/sounds/ocean/stereo/audio-volume-change.oga
osd() {   # osd <title> <percent> <icon>
    local p="$2" bar; bar="$(python3 -c "p=int($p); n=round(min(p,150)/10); print('▰'*n+'▱'*(15-n))")"
    notify-send -a Volume -r 9991 -t 1200 -i "$3" "$1" "$bar  $p%"
}
vol() { wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2*100}'; }
case "${1:-}" in
    up)   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic)  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
          if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then notify-send -a Volume -r 9992 -t 1200 -i microphone-sensitivity-muted "Microphone muted"
          else notify-send -a Volume -r 9992 -t 1200 -i microphone-sensitivity-high "Microphone on"; fi
          exit 0 ;;
    *) echo "usage: $0 up|down|mute|mic"; exit 1 ;;
esac
if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
    notify-send -a Volume -r 9991 -t 1200 -i audio-volume-muted "Muted"
else
    v="$(vol)"; icon=audio-volume-high; [ "$v" -lt 66 ] && icon=audio-volume-medium; [ "$v" -lt 33 ] && icon=audio-volume-low
    osd "Volume" "$v" "$icon"
    [ -f "$SND" ] && pw-play "$SND" >/dev/null 2>&1 &
fi
