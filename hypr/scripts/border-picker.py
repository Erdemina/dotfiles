#!/usr/bin/env python3
"""Kenarlık rengi seçici — liste + canlı önizleme (wallpaper-picker.py ile aynı mantık).

border-picker.py <mevcut c1→c2> "Ad (c1→c2)"...
  Ok tuşları / fare ile gezerken vurgulanan renk anında uygulanır (hyprctl eval, dosyaya yazmaz).
  Üstteki kutuya "aabbcc→ddeeff" ya da tek "aabbcc" yazınca özel renk canlı önizlenir.
  Enter / tık: seçimi "Ad (c1→c2)" olarak stdout'a yazar ve 0 ile çıkar (çağıran dosyalara yazar);
  Esc: eski rengi geri yükler, 1 ile çıkar.
"""
import re
import subprocess
import sys

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402

GLib.set_prgname("hypr.border-picker")   # Wayland app-id → rules.lua yüzen pencere kuralı

PREVIEW_DELAY_MS = 40
HEX = r"[0-9a-f]{6}"
PAIR = re.compile(rf"^({HEX})(?:→({HEX}))?$")

CSS = """
window { background-color: rgba(0, 0, 0, 0.82); border: 2px solid #%(c1)s; border-radius: 10px; }
* { font-family: "Noto Sans"; }
entry { background-color: rgba(30, 30, 30, 0.9); color: #ffffff; border: 0; border-radius: 6px;
        padding: 6px 10px; font-size: 13px; margin: 6px 6px 0 6px; caret-color: #%(c1)s; }
row { border-radius: 8px; padding: 4px 8px; color: #ffffff; }
row:hover { background-color: #111111; }
row:selected { background-color: rgba(%(r)d, %(g)d, %(b)d, 0.15); color: #%(bright)s; font-weight: bold; }
.swatch { border-radius: 6px; min-width: 96px; min-height: 22px; }
.name { font-size: 13px; }
.name.current { font-weight: bold; }
.hex { font-family: monospace; font-size: 11px; opacity: 0.7; }
scrolledwindow { border: 0; }
"""


def parse(text):
    """'aabbcc→ddeeff' | 'aabbcc' → (c1, c2) ya da None"""
    m = PAIR.match(text.strip().lstrip("#").replace(" ", "").lower())
    return (m.group(1), m.group(2) or m.group(1)) if m else None


def hypr_set(c1, c2):
    grad = '{ colors = { "rgba(%see)", "rgba(%see)" }, angle = 30 }' % (c1, c2)
    subprocess.Popen(["hyprctl", "eval",
                      "hl.config({ general = { col = { active_border = %s } }, group = { col = { border_active = %s } } })" % (grad, grad)],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


class Picker(Gtk.Window):
    def __init__(self, current, presets):
        super().__init__(title="Border colour")
        self.current = parse(current)
        self.result = 1
        self.choice = None
        self._preview_id = None
        self._previewed = None

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)
        self.set_decorated(False)
        self.set_default_size(420, 560)
        self.style = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_screen(screen, self.style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self.swatch_css = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_screen(screen, self.swatch_css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self.set_accent(self.current[0] if self.current else "89b4fa")

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(box)

        self.entry = Gtk.Entry(placeholder_text="Özel: aabbcc→ddeeff   ·   ↑↓ canlı önizleme   ·   Enter / tık: uygula   ·   Esc: vazgeç")
        self.entry.connect("changed", self.on_entry)
        self.entry.connect("activate", lambda *_: self.apply_entry())
        box.pack_start(self.entry, False, False, 0)

        scroller = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER)
        box.pack_start(scroller, True, True, 0)
        self.list = Gtk.ListBox(selection_mode=Gtk.SelectionMode.SINGLE, activate_on_single_click=True, margin=6)
        self.list.connect("row-selected", self.on_selection)
        self.list.connect("row-activated", lambda _l, row: self.apply(row.label))
        scroller.add(self.list)

        css = []
        for i, p in enumerate(presets):
            m = re.match(r"^(.*?)\s*\((.*)\)\s*$", p)
            if not m or not parse(m.group(2)):
                continue
            c1, c2 = parse(m.group(2))
            css.append(".sw%d { background-image: linear-gradient(120deg, #%s, #%s); }" % (i, c1, c2))
            self.list.add(self.make_row(i, m.group(1), c1, c2))
        self.swatch_css.load_from_data("\n".join(css).encode())

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)
        self.show_all()

        # Mevcut renk seçili başlasın
        for row in self.list.get_children():
            if row.pair == self.current:
                self.list.select_row(row); row.grab_focus(); break
        else:
            first = self.list.get_row_at_index(0)
            if first:
                self.list.select_row(first); first.grab_focus()

    # ── liste ──────────────────────────────────────────────────────────
    def make_row(self, i, name, c1, c2):
        row = Gtk.ListBoxRow(); row.pair = (c1, c2); row.label = "%s (%s→%s)" % (name, c1, c2)
        h = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        sw = Gtk.Box(); sw.get_style_context().add_class("swatch"); sw.get_style_context().add_class("sw%d" % i)
        h.pack_start(sw, False, False, 0)
        cur = row.pair == self.current
        lbl = Gtk.Label(label=name + ("  ✓" if cur else ""), xalign=0); lbl.get_style_context().add_class("name")
        if cur:
            lbl.get_style_context().add_class("current")
        h.pack_start(lbl, True, True, 0)
        hx = Gtk.Label(label="%s→%s" % (c1, c2)); hx.get_style_context().add_class("hex")
        h.pack_end(hx, False, False, 0)
        ev = Gtk.EventBox(); ev.add(h); ev.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK)
        ev.connect("enter-notify-event", lambda *_: self.list.select_row(row))   # fare üzerine gelince → önizleme
        row.add(ev)
        return row

    def set_accent(self, c1):
        r, g, b = (int(c1[i:i + 2], 16) for i in (0, 2, 4))
        bright = "%02x%02x%02x" % tuple(round(c + (255 - c) * 0.25) for c in (r, g, b))   # metin için biraz açılmış ton
        self.style.load_from_data((CSS % {"c1": c1, "r": r, "g": g, "b": b, "bright": bright}).encode())

    # ── önizleme / uygula ──────────────────────────────────────────────
    def schedule_preview(self, pair):
        if self._preview_id:
            GLib.source_remove(self._preview_id)
        self._preview_id = GLib.timeout_add(PREVIEW_DELAY_MS, self.preview, pair)

    def preview(self, pair):
        self._preview_id = None
        if pair != self._previewed:
            self._previewed = pair
            hypr_set(*pair)
            self.set_accent(pair[0])
        return False

    def on_selection(self, _l, row):
        if row:
            self.schedule_preview(row.pair)

    def on_entry(self, entry):
        pair = parse(entry.get_text())
        if pair:
            self.schedule_preview(pair)

    def apply_entry(self):
        pair = parse(self.entry.get_text())
        if pair:
            self.apply("Custom (%s→%s)" % pair)
        else:
            self.apply_selected()

    def apply_selected(self):
        row = self.list.get_selected_row()
        if row:
            self.apply(row.label)

    def apply(self, label):
        self.result = 0
        self.choice = label
        Gtk.main_quit()

    def on_key(self, _w, event):
        key = Gdk.keyval_name(event.keyval)
        in_entry = self.entry.has_focus()
        if key == "Escape":
            Gtk.main_quit(); return True
        if key in ("Up", "Down") and in_entry:
            row = self.list.get_selected_row() or self.list.get_row_at_index(0)
            if row:
                self.list.select_row(row); row.grab_focus()
            return True
        if not in_entry and (key == "BackSpace" or (event.string and event.string.isprintable())):
            # Listedeyken yazmaya başlayınca özel renk kutusuna geç
            self.entry.grab_focus_without_selecting()
            text = self.entry.get_text()
            self.entry.set_text(text[:-1] if key == "BackSpace" else text + event.string)
            self.entry.set_position(-1)
            return True
        return False


def main():
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    win = Picker(sys.argv[1], sys.argv[2:])
    Gtk.main()
    if win.result == 0:
        print(win.choice)
    elif win.current:
        hypr_set(*win.current)   # vazgeçildi → eski renk
    sys.exit(win.result)


if __name__ == "__main__":
    main()
