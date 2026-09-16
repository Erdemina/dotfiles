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
hl.bind(mod .. " + Q",      hl.dsp.exec_cmd(terminal),    { description = "Terminal (ghostty) — KDE custom Meta+Q" })
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal),    { description = "Terminal (ghostty)" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager), { description = "File manager (Dolphin)" })
hl.bind(mod .. " + R",      hl.dsp.exec_cmd(launcher),    { description = "App launcher (rofi)" })
hl.bind("Super_L",          hl.dsp.exec_cmd("pkill rofi || " .. launcher), { release = true, description = "App launcher (rofi) — tap Meta" })
hl.bind(mod .. " + L",      hl.dsp.exec_cmd(lock),        { description = "Lock screen" })
hl.bind(mod .. " + V",      hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i -p 'Pano' | cliphist decode | wl-copy"), { description = "Clipboard history" })
hl.bind(mod .. " + M",      hl.dsp.exec_cmd(powermenu),   { description = "Power menu" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(powermenu), { description = "Power menu" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(scripts .. "/wallpaper.sh pick"), { description = "Wallpaper picker (synced with KDE)" })
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"), { description = "Dismiss notifications" })
hl.bind(mod .. " + I",         hl.dsp.exec_cmd(scripts .. "/settings.sh"), { description = "Hyprland settings menu" })

-- ── Screenshot / OCR / recording (Spectacle KWin istiyor → grim+satty+tesseract) ─
local shot = scripts .. "/screenshot.sh"
hl.bind("Print",                   hl.dsp.exec_cmd(shot .. " menu"),   { description = "Screenshot menu (region / full / window / OCR / record)" })
hl.bind(mod .. " + SHIFT + W",     hl.dsp.exec_cmd(shot .. " region"), { description = "Screenshot: region (same key as KDE)" })
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd(shot .. " region"), { description = "Screenshot: region" })
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd(shot .. " window"), { description = "Screenshot: active window" })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(shot .. " full"),   { description = "Screenshot: full screen" })
hl.bind(mod .. " + SHIFT + T",     hl.dsp.exec_cmd(shot .. " ocr"),    { description = "OCR: copy text from screen region" })
hl.bind(mod .. " + SHIFT + R",     hl.dsp.exec_cmd(shot .. " record"), { description = "Screen recording start/stop (KDE: Meta+Shift+R)" })

-- ── Pencere ─────────────────────────────────────────────────────────────
hl.bind(mod .. " + C",     hl.dsp.window.close(),      { description = "Close window" })
hl.bind("ALT + F4",        hl.dsp.window.close(),      { description = "Close window" })
hl.bind(mod .. " + F",     hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })
hl.bind(mod .. " + Prior", hl.dsp.window.fullscreen({ mode = "maximized" }),  { description = "Maximize" })
hl.bind(mod .. " + Next",  hl.dsp.window.move({ workspace = "special:magic" }), { description = "Minimize → scratchpad" })
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float(), { description = "Toggle floating" })
hl.bind(mod .. " + P",     hl.dsp.window.pseudo(),     { description = "Pseudotile" })
hl.bind(mod .. " + J",     hl.dsp.layout("togglesplit"), { description = "Toggle split direction" })
hl.bind(mod .. " + G",     hl.dsp.group.toggle(),      { description = "Toggle tabbed group" })
hl.bind(mod .. " + SHIFT + G", hl.dsp.group.next(),    { description = "Next window in group" })
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.center(), { description = "Center window" })
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pin(),    { description = "Pin window (all workspaces)" })

-- Alt+Tab / Meta+Tab: pencereler arasında dolaş (KDE)
local function cycle(next)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = next }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end
hl.bind("ALT + Tab",          cycle(true),  { description = "Next window" })
hl.bind("ALT + SHIFT + Tab",  cycle(false), { description = "Previous window" })
hl.bind(mod .. " + Tab",      cycle(true),  { description = "Next window" })

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
-- Hyprland 0.56: herhangi bir tuşa basınca sürükleme biter ve pencere yerinde kalır.
-- Bu yüzden sürükleme durumunu Lua'da izliyoruz: sürüklerken Meta+N → pencere N'e taşınır ve takip edilir.
local dragging = false
hl.bind(mod .. " + mouse:272", function() dragging = true  end, { non_consuming = true })
hl.bind(mod .. " + mouse:272", function() dragging = false end, { release = true, ignore_mods = true, non_consuming = true })
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Çalışma alanları (KDE özel: Meta+1..6 masaüstü) ─────────────────────
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, function()
        if dragging then   -- sürüklenen pencere (odaklı) ile birlikte git
            dragging = false
            hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = i }))
        end
    end, { description = "Workspace " .. i .. " (while dragging: move window there)" })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(mod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad (dotfiles)
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Send to scratchpad" })

-- ── Medya / parlaklık (kilit ekranında da çalışır) ───────────────────────
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        held)
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind(mod .. " + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), held)
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), held)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
