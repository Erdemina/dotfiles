#!/usr/bin/env python3
"""waybar custom module: workspaces as ONE label (no add/remove flicker).
Listens to Hyprland's event socket and reprints on every change."""
import json, os, socket, subprocess, sys, html

ACCENT = "#89b4fa"; ACCENT_FG = "#11111b"; DIM = "#7984a4"; FG = "#cdd6f4"
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
            parts.append(f'<span background="{ACCENT}" foreground="{ACCENT_FG}" weight="bold"> {i} </span>')
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
