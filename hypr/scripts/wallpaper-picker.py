#!/usr/bin/env python3
"""Duvar kağıdı seçici — küçük resim ızgarası, canlı önizleme.

wallpaper-picker.py <mevcut> <dosya>...
  Ok tuşları / fare ile gezerken vurgulanan duvar kağıdı anında uygulanır (wallpaper.sh preview),
  Enter / tık kalıcı yapar (wallpaper.sh set) ve 0 ile çıkar, Esc 1 ile çıkar (çağıran eskisine döner).
Küçük resimler ~/.cache/wallpaper-picker/ altında saklanır (ilk açılışta arka planda üretilir).
"""
import hashlib
import os
import subprocess
import sys
import threading

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk, Pango  # noqa: E402

GLib.set_prgname("hypr.wallpaper-picker")   # Wayland app-id → rules.lua yüzen pencere kuralı

WALLPAPER_SH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "wallpaper.sh")
CACHE = os.path.join(GLib.get_user_cache_dir(), "wallpaper-picker")
THUMB_W, THUMB_H = 256, 144
COLUMNS = 4
PREVIEW_DELAY_MS = 40          # tuşa basılı tutarken her kareyi yüklememek için (küçük tutuluyor)

CSS = b"""
window { background-color: rgba(0, 0, 0, 0.82); border: 2px solid #89b4fa; border-radius: 10px; }
* { font-family: "Noto Sans"; }
entry { background-color: rgba(30, 30, 30, 0.9); color: #ffffff; border: 0; border-radius: 6px;
        padding: 6px 10px; font-size: 13px; margin: 6px 6px 0 6px; caret-color: #89b4fa; }
flowboxchild { border-radius: 8px; padding: 6px; color: #ffffff; }
flowboxchild:hover { background-color: #111111; }
flowboxchild:selected { background-color: #89b4fa; color: #11111b; }
.thumb { border-radius: 4px; }
.name { font-size: 12px; }
.name.current { font-weight: bold; }
scrolledwindow { border: 0; }
"""


def thumb_path(path):
    st = os.stat(path)
    key = hashlib.sha1(f"{path}:{st.st_mtime_ns}:{THUMB_W}".encode()).hexdigest()
    return os.path.join(CACHE, key + ".png")


def make_thumb(path):
    dst = thumb_path(path)
    if not os.path.exists(dst):
        pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, THUMB_W, THUMB_H, True)
        pb.savev(dst, "png", [], [])
    return dst


class Picker(Gtk.Window):
    def __init__(self, current, files):
        super().__init__(title="Wallpaper")
        self.current, self.files = current, files
        self.result = 1
        self._preview_id = None
        self._previewed = None

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)
        self.set_decorated(False)
        self.set_default_size(1160, 470)   # 4 sütun × 2 satır
        style = Gtk.CssProvider(); style.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(screen, style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(box)

        self.entry = Gtk.SearchEntry(placeholder_text="Ara…   ·   ↑↓←→ canlı önizleme   ·   Enter / tık: uygula   ·   Esc: vazgeç")
        self.entry.connect("search-changed", lambda *_: self.flow.invalidate_filter())
        self.entry.connect("activate", lambda *_: self.apply_selected())
        box.pack_start(self.entry, False, False, 0)

        scroller = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER)
        box.pack_start(scroller, True, True, 0)
        self.flow = Gtk.FlowBox(
            selection_mode=Gtk.SelectionMode.SINGLE, homogeneous=True,
            min_children_per_line=COLUMNS, max_children_per_line=COLUMNS,
            activate_on_single_click=True, row_spacing=6, column_spacing=6, margin=6,
        )
        self.flow.set_filter_func(self.filter_child)
        self.flow.connect("selected-children-changed", self.on_selection)
        self.flow.connect("child-activated", lambda _f, child: self.apply(child.path))
        scroller.add(self.flow)

        self.images = {}
        for path in files:
            self.flow.add(self.make_child(path))

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)
        self.show_all()

        # Mevcut duvar kağıdı seçili başlasın
        for child in self.flow.get_children():
            if child.path == current:
                self.flow.select_child(child); child.grab_focus(); break
        threading.Thread(target=self.load_thumbs, daemon=True).start()

    # ── ızgara ─────────────────────────────────────────────────────────
    def make_child(self, path):
        name = os.path.splitext(os.path.basename(path))[0]
        child = Gtk.FlowBoxChild(); child.path = path; child.name = name.lower()
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        img = Gtk.Image(); img.set_size_request(THUMB_W, THUMB_H); img.get_style_context().add_class("thumb")
        self.images[path] = img
        label = Gtk.Label(label=name + ("  ✓" if path == self.current else ""), ellipsize=Pango.EllipsizeMode.END, max_width_chars=24)
        label.get_style_context().add_class("name")
        if path == self.current:
            label.get_style_context().add_class("current")
        vbox.pack_start(img, False, False, 0); vbox.pack_start(label, False, False, 0)
        # Fare üzerine gelince seç → canlı önizleme
        ev = Gtk.EventBox(); ev.add(vbox); ev.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK)
        ev.connect("enter-notify-event", lambda *_: self.flow.select_child(child))
        child.add(ev)
        return child

    def load_thumbs(self):
        os.makedirs(CACHE, exist_ok=True)
        for path in self.files:
            try:
                pb = GdkPixbuf.Pixbuf.new_from_file(make_thumb(path))
            except GLib.Error:
                continue
            GLib.idle_add(self.images[path].set_from_pixbuf, pb)

    def filter_child(self, child):
        q = self.entry.get_text().strip().lower()
        return all(tok in child.name for tok in q.split())

    # ── önizleme / uygula ──────────────────────────────────────────────
    def on_selection(self, flow):
        sel = flow.get_selected_children()
        if not sel:
            return
        path = sel[0].path
        if self._preview_id:
            GLib.source_remove(self._preview_id)
        self._preview_id = GLib.timeout_add(PREVIEW_DELAY_MS, self.preview, path)

    def preview(self, path):
        self._preview_id = None
        if path != self._previewed:
            self._previewed = path
            subprocess.Popen([WALLPAPER_SH, "preview", path])
        return False

    def apply_selected(self):
        sel = self.flow.get_selected_children()
        if sel:
            self.apply(sel[0].path)

    def apply(self, path):
        self.result = 0
        subprocess.run([WALLPAPER_SH, "set", path])
        Gtk.main_quit()

    def on_key(self, _w, event):
        key = Gdk.keyval_name(event.keyval)
        in_entry = self.entry.has_focus()
        if key == "Escape":
            Gtk.main_quit(); return True
        if key in ("Up", "Down", "Left", "Right", "Return", "KP_Enter") and in_entry:
            # Arama kutusundan ızgaraya dön; oklar/Enter ızgarada işlenir
            sel = self.flow.get_selected_children() or [c for c in self.flow.get_children() if self.filter_child(c)][:1]
            if sel:
                self.flow.select_child(sel[0]); sel[0].grab_focus()
                if key in ("Return", "KP_Enter"):
                    self.apply(sel[0].path)
            return True
        if not in_entry and (key == "BackSpace" or (event.string and event.string.isprintable())):
            # Izgaradayken yazmaya başlayınca arama kutusuna geç
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
    sys.exit(win.result)


if __name__ == "__main__":
    main()
