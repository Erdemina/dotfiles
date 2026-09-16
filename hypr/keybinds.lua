-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃  Kısayollar                                                ┃
-- ┃  Öncelik: KDE'deki özel kısayollar > KDE varsayılanları    ┃
-- ┃           > eski dotfiles                                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
local mod      = "SUPER"
local scripts  = os.getenv("HOME") .. "/.config/hypr/scripts"

-- KDE uygulamaları
local terminal    = "ghostty"
local fileManager = "dolphin"
local launcher    = "rofi -show drun"
local lock        = "hyprlock"
local powermenu   = scripts .. "/powermenu.sh"

-- ── Uygulamalar ─────────────────────────────────────────────────────────
hl.bind(mod .. " + Q",      hl.dsp.exec_cmd(terminal),    { description = "Ghostty (KDE özel Meta+Q → terminal)" })
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal),    { description = "Ghostty" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager), { description = "Dolphin (KDE: Meta+E)" })
hl.bind(mod .. " + R",      hl.dsp.exec_cmd(launcher),    { description = "Uygulama menüsü (dotfiles: Meta+R)" })
hl.bind("Super_L",          hl.dsp.exec_cmd("pkill rofi || " .. launcher), { release = true, description = "Uygulama menüsü (KDE: tek Meta)" })
hl.bind(mod .. " + L",      hl.dsp.exec_cmd(lock),        { description = "Ekranı kilitle (KDE: Meta+L)" })
hl.bind(mod .. " + V",      hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i -p 'Pano' | cliphist decode | wl-copy"), { description = "Pano geçmişi (KDE Klipper: Meta+V)" })
hl.bind(mod .. " + M",      hl.dsp.exec_cmd(powermenu),   { description = "Güç menüsü" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(powermenu), { description = "Güç menüsü (KDE: Ctrl+Alt+Del)" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(scripts .. "/wallpaper.sh pick"), { description = "Duvar kağıdı seç (KDE ile senkron)" })
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"), { description = "Bildirimleri kapat" })
hl.bind(mod .. " + I",         hl.dsp.exec_cmd(scripts .. "/settings.sh"), { description = "Hyprland ayar menüsü" })

-- ── Ekran görüntüsü: grim+slurp → satty (Spectacle Wayland'de KWin istiyor) ─
local shot = scripts .. "/screenshot.sh"
hl.bind(mod .. " + SHIFT + W",     hl.dsp.exec_cmd(shot .. " region"), { description = "Ekran görüntüsü: bölge (KDE ile aynı kısayol)" })
hl.bind("Print",                   hl.dsp.exec_cmd(shot .. " full"),   { description = "Ekran görüntüsü: tam ekran" })
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd(shot .. " region"), { description = "Ekran görüntüsü: bölge" })
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd(shot .. " window"), { description = "Ekran görüntüsü: aktif pencere" })

-- ── Pencere ─────────────────────────────────────────────────────────────
hl.bind(mod .. " + C",     hl.dsp.window.close(),      { description = "Pencereyi kapat (KDE özel: Meta+C)" })
hl.bind("ALT + F4",        hl.dsp.window.close(),      { description = "Pencereyi kapat" })
hl.bind(mod .. " + F",     hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Tam ekran (KDE özel: Meta+F)" })
hl.bind(mod .. " + Prior", hl.dsp.window.fullscreen({ mode = "maximized" }),  { description = "Büyüt (KDE: Meta+PgUp)" })
hl.bind(mod .. " + Next",  hl.dsp.window.move({ workspace = "special:magic" }), { description = "Küçült → scratchpad (KDE: Meta+PgDown)" })
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float(), { description = "Yüzen/döşeli" })
hl.bind(mod .. " + P",     hl.dsp.window.pseudo(),     { description = "Pseudotile" })
hl.bind(mod .. " + J",     hl.dsp.layout("togglesplit"), { description = "Bölme yönünü değiştir" })
hl.bind(mod .. " + G",     hl.dsp.group.toggle(),      { description = "Sekmeli grup aç/kapat" })
hl.bind(mod .. " + SHIFT + G", hl.dsp.group.next(),    { description = "Gruptaki sonraki pencere" })
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.center(), { description = "Ortala" })
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pin(),    { description = "Sabitle (tüm çalışma alanlarında)" })

-- Alt+Tab / Meta+Tab: pencereler arasında dolaş (KDE)
local function cycle(next)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = next }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end
hl.bind("ALT + Tab",          cycle(true),  { description = "Sonraki pencere" })
hl.bind("ALT + SHIFT + Tab",  cycle(false), { description = "Önceki pencere" })
hl.bind(mod .. " + Tab",      cycle(true),  { description = "Sonraki pencere" })

-- Odak / taşı / boyutlandır
local dirs = { left = "left", right = "right", up = "up", down = "down" }
for key, dir in pairs(dirs) do
    hl.bind(mod .. " + " .. key,             hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ direction = dir }))
end
hl.bind(mod .. " + CTRL + SHIFT + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + SHIFT + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Fare ile taşı / boyutlandır
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Çalışma alanları (KDE özel: Meta+1..6 masaüstü) ─────────────────────
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }), { description = "Önceki çalışma alanı (KDE)" })
hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }), { description = "Sonraki çalışma alanı (KDE)" })
hl.bind(mod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad (dotfiles)
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"), { description = "Scratchpad göster/gizle" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Scratchpad'e taşı" })

-- ── Medya / parlaklık (kilit ekranında da çalışır) ───────────────────────
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        held)
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind(mod .. " + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true, description = "Mikrofonu sustur (KDE: Meta+Mute)" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), held)
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), held)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
