#!/usr/bin/env python3
"""waybar custom module: workspaces as ONE label (no add/remove flicker).
Listens to Hyprland's event socket and reprints on every change."""
import json, os, pathlib, socket, subprocess, sys, html

import re
ACCENT_FG = "#11111b"; DIM = "#7984a4"; FG = "#cdd6f4"

def border_colour():
    """lookandfeel.lua'daki active_border'ın ilk rengi (tek kaynak); Pango gradyan bilmez."""
    try:
        lua = pathlib.Path("~/.config/hypr/lookandfeel.lua").expanduser().read_text()
        return "#" + re.search(r'active_border\s*=\s*\{ colors = \{ "rgba\(([0-9a-fA-F]{6})', lua).group(1)
    except Exception:
        return "#89b4fa"

def brighten(hex_colour, k=0.25):
    """#rrggbb → beyaza doğru k oranında açılmış hâli (parlak/glow hissi)"""
    r, g, b = (int(hex_colour[i:i + 2], 16) for i in (1, 3, 5))
    return "#%02x%02x%02x" % tuple(round(c + (255 - c) * k) for c in (r, g, b))

ACCENT = border_colour()
ACCENT_BRIGHT = brighten(ACCENT)
EVENTS = ("workspace", "createworkspace", "destroyworkspace", "focusedmon",
          "openwindow", "closewindow", "movewindow", "activespecial", "urgent")

def hyprctl(*args):
    return json.loads(subprocess.run(["hyprctl", "-j", *args], capture_output=True, text=True).stdout or "null")

def render():
    ws = [w for w in (hyprctl("workspaces") or []) if w["id"] > 0]
    active = (hyprctl("activeworkspace") or {}).get("id")
    ids = sorted({w["id"] for w in ws} | ({active} if active else set()))
    parts = []
    for i in ids:
        if i == active:
            # rofi / seçicilerle aynı stil: %15 saydam accent zemin + parlatılmış accent metin, kalın ve bir tık büyük
            parts.append(f'<span background="{ACCENT}" background_alpha="15%" foreground="{ACCENT_BRIGHT}" weight="heavy" size="large"> {i} </span>')
        else:
            parts.append(f'<span foreground="{DIM}"> {i} </span>')
    text = "".join(parts) or " "
    tip = "Workspaces — scroll to switch, click to open next"
    print(json.dumps({"text": text, "tooltip": tip, "class": "workspaces"}), flush=True)

def main():
    render()
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    path = f"{os.environ.get('XDG_RUNTIME_DIR', '/run/user/1000')}/hypr/{sig}/.socket2.sock"
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); s.connect(path)
    buf = b""
    while True:
        data = s.recv(4096)
        if not data: break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            if line.split(b">>", 1)[0].decode() in EVENTS:
                render()

if __name__ == "__main__":
    try: main()
    except KeyboardInterrupt: pass
