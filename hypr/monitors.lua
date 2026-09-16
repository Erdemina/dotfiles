-- Monitörler: https://wiki.hypr.land/Configuring/Core/Monitors/
-- Dahili panel 1920x1200@60, ölçek 1 (KDE ile aynı).
hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })
-- Harici monitörler: tercih edilen mod, sağa yerleştir
hl.monitor({ output = "",      mode = "preferred",    position = "auto", scale = 1 })
