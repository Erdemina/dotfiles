#!/usr/bin/env bash
# Screenshot / OCR / screen recording — Spectacle replacement for Hyprland
#   region | full | window   -> grim (+slurp) -> satty editor (Enter: copy+save, Esc: quit)
#   ocr                      -> select region -> tesseract (tur+eng) -> clipboard
#   record                   -> toggle wf-recorder (region), saves to ~/Videos/Screencasts
#   menu                     -> rofi picker (bound to Print)
set -u
DIR="$HOME/Pictures/Screenshots";  mkdir -p "$DIR"
VDIR="$HOME/Videos/Screencasts";   mkdir -p "$VDIR"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
SLURP=(slurp -d -b 00000066 -c 89b4faff -w 2)

capture() {   # capture <region|full|window>  -> PNG on stdout
    case "$1" in
        region) geom="$("${SLURP[@]}")" || return 1; grim -g "$geom" - ;;
        full)   grim - ;;
        window) geom="$(hyprctl activewindow -j | python3 -c 'import json,sys; w=json.load(sys.stdin); print(f"{w[\"at\"][0]},{w[\"at\"][1]} {w[\"size\"][0]}x{w[\"size\"][1]}")')"
                grim -g "$geom" - ;;
    esac
}

edit() {      # stdin PNG -> satty (or fallback: save + copy)
    if command -v satty >/dev/null; then
        satty --filename - --output-filename "$DIR/$STAMP.png" --copy-command wl-copy \
              --early-exit --actions-on-enter save-to-clipboard --actions-on-escape exit --save-after-copy
    else
        tee "$DIR/$STAMP.png" | wl-copy
        notify-send -a Screenshot -i "$DIR/$STAMP.png" "Saved & copied" "$DIR/$STAMP.png"
    fi
}

ocr() {
    geom="$("${SLURP[@]}")" || return 0
    langs="eng"; [ -f /usr/share/tessdata/tur.traineddata ] && langs="tur+eng"
    text="$(grim -g "$geom" - | tesseract - - -l "$langs" 2>/dev/null | sed -e 's/[[:space:]]*$//' -e '/^$/d')"
    if [ -n "$text" ]; then
        printf '%s' "$text" | wl-copy
        notify-send -a "OCR" "Text copied to clipboard" "$text"
    else
        notify-send -a "OCR" "No text recognized"
    fi
}

record() {
    if pgrep -x wf-recorder >/dev/null; then
        pkill -INT -x wf-recorder; sleep 0.5
        notify-send -a "Screen recording" "Stopped" "Saved to $VDIR"
        pkill -RTMIN+9 waybar 2>/dev/null; return
    fi
    command -v wf-recorder >/dev/null || { notify-send -a "Screen recording" "wf-recorder is not installed"; return 1; }
    geom="$("${SLURP[@]}")" || return 0
    notify-send -a "Screen recording" "Recording…" "Run again (Print → Record) to stop"
    pkill -RTMIN+9 waybar 2>/dev/null
    wf-recorder -g "$geom" -f "$VDIR/$STAMP.mp4" >/dev/null 2>&1 &
}

menu() {
    rec="󰑊  Start recording"; pgrep -x wf-recorder >/dev/null && rec="󰓛  Stop recording"
    c="$(printf '󰩭  Region\n󰍹  Full screen\n󰖯  Active window\n󰊄  Text (OCR) → clipboard\n%s\n󰉏  Open screenshots folder' "$rec" \
        | rofi -dmenu -i -p "Screenshot" -theme-str 'window { width: 320px; } listview { lines: 6; }')"
    case "$c" in
        *Region*)   sleep 0.2; capture region | edit ;;
        *"Full"*)   sleep 0.3; capture full   | edit ;;
        *window*)   sleep 0.3; capture window | edit ;;
        *OCR*)      sleep 0.2; ocr ;;
        *recording*) sleep 0.2; record ;;
        *folder*)   xdg-open "$DIR" ;;
    esac
}

case "${1:-menu}" in
    region|full|window) capture "$1" | edit ;;
    ocr)    ocr ;;
    record) record ;;
    menu)   menu ;;
    status) pgrep -x wf-recorder >/dev/null && echo "󰑊 REC" ;;
    *) echo "usage: $0 region|full|window|ocr|record|menu"; exit 1 ;;
esac
