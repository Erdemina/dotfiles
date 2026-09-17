#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Launch main (waybar kapanınca mediaplayer.py yetim kalıyor — onları da kapat)
pkill -f "$HOME/.config/waybar/mediaplayer.py"; pkill -f "$HOME/.config/hypr/scripts/workspaces.py"
waybar &
