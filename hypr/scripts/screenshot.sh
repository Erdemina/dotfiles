#!/usr/bin/env bash
# Ekran görüntüsü — grim + slurp → satty (düzenleyici). satty yoksa hyprshot'a düşer.
#   screenshot.sh region | full | window
set -u
DIR="$HOME/Pictures/Screenshots"; mkdir -p "$DIR"
OUT="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
mode="${1:-region}"

if ! command -v satty >/dev/null; then
    case "$mode" in region) m=region;; full) m=output;; window) m=window;; esac
    exec hyprshot -m "$m" -o "$DIR"
fi

case "$mode" in
    region) geom="$(slurp -d -b 00000066 -c 89b4faff -w 2)" || exit 0
            grim -g "$geom" - ;;
    full)   grim - ;;
    window) geom="$(hyprctl activewindow -j | python3 -c 'import json,sys; w=json.load(sys.stdin); print(f"{w[\"at\"][0]},{w[\"at\"][1]} {w[\"size\"][0]}x{w[\"size\"][1]}")')"
            grim -g "$geom" - ;;
    *) echo "kullanım: $0 region|full|window"; exit 1 ;;
esac | satty --filename - --output-filename "$OUT" --copy-command wl-copy \
        --early-exit --actions-on-enter save-to-clipboard --actions-on-escape exit \
        --initial-tool crop --save-after-copy
