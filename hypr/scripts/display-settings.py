#!/usr/bin/env python3
"""Arrange connected Hyprland outputs, choose modes, and select Waybar outputs."""
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, Gtk  # noqa: E402

H = Path.home() / ".config/hypr/monitors.lua"
W = Path.home() / ".config/waybar/config"
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "hypr/display-waybar.json"
WORKSPACES = STATE.with_name("display-workspaces.json")
WS_START = "-- Display workspaces: begin"
WS_END = "-- Display workspaces: end"
START = "-- Display settings: begin"
END = "-- Display settings: end"
MODE = re.compile(r"^\d+x\d+@\d+(?:\.\d+)?Hz$")


def monitors():
    result = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True, check=True)
    return [m for m in json.loads(result.stdout) if not m.get("disabled") and m.get("mirrorOf", "none") == "none"]


def waybar_outputs(text):
    match = re.search(r'^[ \t]*"output"[ \t]*:[ \t]*(\[[^]]*\]|"[^"]*")[ \t]*,?', text, re.M)
    return (match, json.loads(match.group(1))) if match else (None, None)


def layout_key(names):
    return "|".join(sorted(names))


def preferences():
    if STATE.exists():
        return json.loads(STATE.read_text())
    # Preserve the last layout saved by the old editor, even if it is unplugged now.
    text = H.read_text()
    block = text.split(START, 1)[1].split(END, 1)[0] if START in text and END in text else ""
    names = re.findall(r'hl\.monitor\(\{\s*output\s*=\s*"([^"]+)"', block)
    _, outputs = waybar_outputs(W.read_text())
    return {layout_key(names): outputs} if names and isinstance(outputs, list) else {}


def selected_outputs(names, saved):
    return [name for name in names if name in saved.get(layout_key(names), names)]


def workspace_preferences():
    return json.loads(WORKSPACES.read_text()) if WORKSPACES.exists() else {}


def fixed_workspaces(names, saved):
    configured = saved.get(layout_key(names), {})
    return {name: configured[name] for name in names if name in configured}


def workspace_rules(text, assignments):
    if WS_START in text and WS_END in text:
        text = re.sub(r"\n*" + re.escape(WS_START) + r".*?" + re.escape(WS_END) + r"\n?",
                      "\n", text, count=1, flags=re.S).rstrip() + "\n"
    if not assignments:
        return text
    rules = [WS_START]
    for name, number in sorted(assignments.items()):
        rules.append(f'hl.workspace_rule({{ workspace = "{number}", monitor = {json.dumps(name)}, default = true, persistent = true }})')
    # keybinds.lua reads this module result to keep workspace shortcuts off sticky screens.
    rules.append("return { " + ", ".join(
        f'[{json.dumps(name)}] = {number}' for name, number in sorted(assignments.items())) + " }")
    rules.append(WS_END)
    return text.rstrip() + "\n\n" + "\n".join(rules) + "\n"


def sync_workspaces(names):
    old = H.read_text()
    new = workspace_rules(old, fixed_workspaces(names, workspace_preferences()))
    if new == old:
        return
    H.write_text(new)
    try:
        check = subprocess.run(["Hyprland", "--verify-config"], capture_output=True, text=True)
        if check.returncode:
            raise RuntimeError(check.stderr or check.stdout)
        reload = subprocess.run(["hyprctl", "reload"], capture_output=True, text=True)
        if reload.returncode:
            raise RuntimeError(reload.stderr or reload.stdout)
    except Exception:
        H.write_text(old)
        subprocess.run(["hyprctl", "reload"], capture_output=True)
        raise
    place_fixed_workspaces(fixed_workspaces(names, workspace_preferences()))


def place_fixed_workspaces(assignments):
    if not assignments:
        return
    existing = {w["id"] for w in json.loads(subprocess.run(
        ["hyprctl", "workspaces", "-j"], capture_output=True, text=True, check=True).stdout)}
    for name, number in assignments.items():
        if number in existing:
            subprocess.run(["hyprctl", "dispatch",
                            f'hl.dsp.workspace.move({{ workspace = {number}, monitor = {json.dumps(name)} }})'],
                           check=True, capture_output=True, text=True)
        subprocess.run(["hyprctl", "dispatch", f'hl.dsp.focus({{ workspace = {number} }})'],
                       check=True, capture_output=True, text=True)


def set_waybar_outputs(outputs):
    old = W.read_text()
    field = '    "output": ' + json.dumps(outputs, ensure_ascii=False) + ','
    match, _ = waybar_outputs(old)
    if match:
        new = old[:match.start()] + field + old[match.end():]
    else:
        new = old.replace('    "position": "top",', '    "position": "top",\n' + field, 1)
        if new == old:
            raise ValueError("Waybar position setting not found")
    if new != old:
        W.write_text(new)
    return new != old


def restart_waybar(outputs):
    subprocess.run(["pkill", "-x", "waybar"], capture_output=True)
    if outputs:
        subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)


def sync_waybar():
    names = [m["name"] for m in monitors()]
    if not names:
        return
    saved = preferences()
    if not STATE.exists():
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(json.dumps(saved, ensure_ascii=False, indent=2) + "\n")
    sync_workspaces(names)
    outputs = selected_outputs(names, saved)
    changed = set_waybar_outputs(outputs)
    if changed or (outputs and subprocess.run(["pgrep", "-x", "waybar"], capture_output=True).returncode):
        restart_waybar(outputs)


def watch():
    runtime = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr" / os.environ["HYPRLAND_INSTANCE_SIGNATURE"] / ".socket2.sock"
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as events:
        events.connect(str(runtime))
        sync_waybar()
        with events.makefile() as stream:
            for line in stream:
                if line.startswith(("monitoradded>>", "monitoraddedv2>>", "monitorremoved>>", "monitorremovedv2>>")):
                    sync_waybar()


def save(monitors_list, outputs):
    saved = preferences()
    assignments = {m["name"]: m["workspace"] for m in monitors_list if m["workspace"]}
    if len(set(assignments.values())) != len(assignments):
        raise ValueError("Aynı çalışma alanı iki ekrana sabitlenemez.")
    old_h, old_w = H.read_text(), W.read_text()
    lines = [START]
    for m in monitors_list:
        name = m["name"]
        mode = m["chosen_mode"].removesuffix("Hz")
        x, y = m["x"], m["y"]
        scale = m["scale"]
        lines.append(f'hl.monitor({{ output = {json.dumps(name)}, mode = {json.dumps(mode)}, position = "{x}x{y}", scale = {scale:g} }})')
    lines.append(END)
    block = "\n".join(lines)
    if START in old_h and END in old_h:
        new_h = re.sub(re.escape(START) + r".*?" + re.escape(END), lambda _: block, old_h, count=1, flags=re.S)
    else:
        new_h = old_h.rstrip() + "\n\n" + block + "\n"
    new_h = workspace_rules(new_h, assignments)
    match, _ = waybar_outputs(old_w)
    field = '    "output": ' + json.dumps(outputs, ensure_ascii=False) + ','
    if match:
        new_w = old_w[:match.start()] + field + old_w[match.end():]
    else:
        new_w = old_w.replace('    "position": "top",', '    "position": "top",\n' + field, 1)
        if new_w == old_w:
            raise ValueError("Waybar position setting not found")
    key = layout_key(m["name"] for m in monitors_list)
    old_state = STATE.read_text() if STATE.exists() else None
    old_workspaces = WORKSPACES.read_text() if WORKSPACES.exists() else None
    saved[key] = outputs
    workspaces = workspace_preferences()
    workspaces[key] = assignments
    # Publish preferences before reload, so the hotplug watcher sees the new layout.
    try:
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(json.dumps(saved, ensure_ascii=False, indent=2) + "\n")
        WORKSPACES.write_text(json.dumps(workspaces, ensure_ascii=False, indent=2) + "\n")
        H.write_text(new_h)
        W.write_text(new_w)
        check = subprocess.run(["Hyprland", "--verify-config"], capture_output=True, text=True)
        if check.returncode:
            raise RuntimeError(check.stderr or check.stdout)
        reload = subprocess.run(["hyprctl", "reload"], capture_output=True, text=True)
        if reload.returncode:
            raise RuntimeError(reload.stderr or reload.stdout)
    except Exception:
        H.write_text(old_h)
        W.write_text(old_w)
        if old_state is None:
            STATE.unlink(missing_ok=True)
        else:
            STATE.write_text(old_state)
        if old_workspaces is None:
            WORKSPACES.unlink(missing_ok=True)
        else:
            WORKSPACES.write_text(old_workspaces)
        subprocess.run(["hyprctl", "reload"], capture_output=True)
        raise
    if assignments:
        place_fixed_workspaces(assignments)
    if new_w != old_w:
        restart_waybar(outputs)


class Editor(Gtk.Window):
    def __init__(self, screens):
        super().__init__(title="Ekran düzeni")
        self.screens = screens
        self.drag = None
        self.selected = 0
        self.set_default_size(940, 660)
        self.connect("destroy", Gtk.main_quit)
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10, margin=14)
        self.add(root)
        root.pack_start(Gtk.Label(label="Ekranları sürükleyip yerleştirin; her ekran için Hz, Waybar ve çalışma alanı seçin.", xalign=0), False, False, 0)
        self.canvas = Gtk.DrawingArea()
        self.canvas.set_size_request(880, 410)
        self.canvas.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.POINTER_MOTION_MASK)
        self.canvas.connect("draw", self.draw)
        self.canvas.connect("button-press-event", self.press)
        self.canvas.connect("motion-notify-event", self.motion)
        self.canvas.connect("button-release-event", self.release)
        root.pack_start(self.canvas, True, True, 0)
        self.details = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        root.pack_start(self.details, False, False, 0)
        self.heading = Gtk.Label(xalign=0)
        self.details.pack_start(self.heading, True, True, 0)
        self.modes = Gtk.ComboBoxText()
        self.modes.connect("changed", self.mode_changed)
        self.details.pack_start(self.modes, False, False, 0)
        self.bar = Gtk.CheckButton(label="Bu ekranda Waybar")
        self.details.pack_start(self.bar, False, False, 0)
        self.workspace = Gtk.ComboBoxText()
        self.workspace.append_text("Serbest (mevcut davranış)")
        self.workspace.append_text("Yapışkan yan ekran (hep görünür)")
        self.workspace.connect("changed", self.workspace_changed)
        self.details.pack_start(self.workspace, False, False, 0)
        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        root.pack_end(buttons, False, False, 0)
        cancel = Gtk.Button(label="Vazgeç")
        cancel.connect("clicked", lambda *_: self.destroy())
        buttons.pack_end(cancel, False, False, 0)
        apply = Gtk.Button(label="Uygula")
        apply.connect("clicked", self.apply)
        buttons.pack_end(apply, False, False, 0)
        self.bar.connect("toggled", self.bar_changed)
        self.fit()
        self.choose(0)
        self.show_all()

    def fit(self):
        left = min(m["x"] for m in self.screens)
        top = min(m["y"] for m in self.screens)
        right = max(m["x"] + m["width"] / m["scale"] for m in self.screens)
        bottom = max(m["y"] + m["height"] / m["scale"] for m in self.screens)
        self.zoom = min(0.33, 820 / max(1, right - left), 350 / max(1, bottom - top))
        self.origin = (35 - left * self.zoom, 30 - top * self.zoom)
        self.canvas.queue_draw()

    def rect(self, m):
        z = self.zoom
        return (self.origin[0] + m["x"] * z, self.origin[1] + m["y"] * z,
                m["width"] / m["scale"] * z, m["height"] / m["scale"] * z)

    def draw(self, _widget, cr):
        cr.set_source_rgb(0.12, 0.13, 0.17)
        cr.paint()
        for index, m in enumerate(self.screens):
            x, y, w, h = self.rect(m)
            cr.set_source_rgb(*( (0.22, 0.37, 0.58) if index == self.selected else (0.25, 0.27, 0.34)))
            cr.rectangle(x, y, w, h)
            cr.fill_preserve()
            cr.set_line_width(3)
            cr.set_source_rgb(*( (0.55, 0.75, 1) if index == self.selected else (0.55, 0.57, 0.63)))
            cr.stroke()
            cr.set_source_rgb(1, 1, 1)
            cr.select_font_face("Sans", 0, 1)
            cr.set_font_size(16)
            cr.move_to(x + 12, y + 28)
            cr.show_text(m["name"])
            cr.set_font_size(12)
            cr.move_to(x + 12, y + 48)
            cr.show_text(m["chosen_mode"] + ("  ·  Waybar" if m["bar"] else "") +
                         ("  ·  Yapışkan" if m["workspace"] else ""))
        return False

    def choose(self, index):
        self.selected = index
        m = self.screens[index]
        self.heading.set_text(m["name"] + "  ·  " + m.get("description", ""))
        self.modes.remove_all()
        modes = list(dict.fromkeys(mode for mode in m["availableModes"] if MODE.fullmatch(mode)))
        if m["chosen_mode"] not in modes:
            modes.insert(0, m["chosen_mode"])
        for mode in modes:
            self.modes.append_text(mode)
        self.modes.set_active(modes.index(m["chosen_mode"]))
        self.bar.set_active(m["bar"])
        self.workspace.set_active(1 if m["workspace"] else 0)
        self.canvas.queue_draw()

    def mode_changed(self, combo):
        if combo.get_active_text():
            m = self.screens[self.selected]
            m["chosen_mode"] = combo.get_active_text()
            size = m["chosen_mode"].split("@", 1)[0]
            m["width"], m["height"] = map(int, size.split("x"))
            self.fit()

    def bar_changed(self, button):
        self.screens[self.selected]["bar"] = button.get_active()
        self.canvas.queue_draw()

    def workspace_changed(self, combo):
        if combo.get_active() >= 0:
            m = self.screens[self.selected]
            if combo.get_active() == 0:
                m["workspace"] = None
            elif not m["workspace"]:
                # Hyprland requires a workspace per monitor; keep its number internal.
                active = m["activeWorkspace"]["id"]
                m["workspace"] = active if active > 0 else max(
                    (s["activeWorkspace"]["id"] for s in self.screens if s["activeWorkspace"]["id"] > 0), default=0) + 1
            self.canvas.queue_draw()

    def press(self, _widget, event):
        if event.button != 1:
            return False
        for i in reversed(range(len(self.screens))):
            x, y, w, h = self.rect(self.screens[i])
            if x <= event.x <= x + w and y <= event.y <= y + h:
                self.choose(i)
                self.drag = (event.x, event.y, self.screens[i]["x"], self.screens[i]["y"])
                return True
        return False

    def motion(self, _widget, event):
        if self.drag:
            px, py, x, y = self.drag
            m = self.screens[self.selected]
            m["x"] = round(x + (event.x - px) / self.zoom)
            m["y"] = round(y + (event.y - py) / self.zoom)
            self.canvas.queue_draw()
        return bool(self.drag)

    def release(self, _widget, event):
        if not self.drag or event.button != 1:
            return False
        self.motion(_widget, event)
        m = self.screens[self.selected]
        width, height = m["width"] / m["scale"], m["height"] / m["scale"]
        candidates = []
        for other in self.screens:
            if other is m:
                continue
            ow, oh = other["width"] / other["scale"], other["height"] / other["scale"]
            if max(m["y"], other["y"]) < min(m["y"] + height, other["y"] + oh):
                candidates.extend([(abs(m["x"] - (other["x"] + ow)), "x", other["x"] + ow), (abs(m["x"] + width - other["x"]), "x", other["x"] - width)])
            if max(m["x"], other["x"]) < min(m["x"] + width, other["x"] + ow):
                candidates.extend([(abs(m["y"] - (other["y"] + oh)), "y", other["y"] + oh), (abs(m["y"] + height - other["y"]), "y", other["y"] - height)])
        if candidates:
            distance, axis, value = min(candidates)
            if distance * self.zoom < 22:
                m[axis] = round(value)
        self.drag = None
        self.fit()
        return True

    def apply(self, _button):
        outputs = [m["name"] for m in self.screens if m["bar"]]
        try:
            save(self.screens, outputs)
        except Exception as exc:
            self.error(str(exc))
            return
        self.destroy()

    def error(self, message):
        dialog = Gtk.MessageDialog(transient_for=self, flags=0, message_type=Gtk.MessageType.ERROR,
                                   buttons=Gtk.ButtonsType.CLOSE, text="Ekran ayarları uygulanamadı")
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()


def main():
    try:
        screens = monitors()
        if not screens:
            raise RuntimeError("Bağlı ekran bulunamadı")
        saved = preferences()
        selected = selected_outputs([m["name"] for m in screens], saved)
        fixed = fixed_workspaces([m["name"] for m in screens], workspace_preferences())
        for m in screens:
            m["chosen_mode"] = f'{m["width"]}x{m["height"]}@{m["refreshRate"]:.2f}Hz'
            m["bar"] = m["name"] in selected
            m["workspace"] = fixed.get(m["name"])
        Editor(screens)
        Gtk.main()
    except Exception as exc:
        print(f"Ekran ayarları: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if sys.argv[1:] == ["--watch"]:
        watch()
    else:
        main()
