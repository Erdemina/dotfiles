-- Giriş aygıtları: KDE ayarlarıyla uyumlu
hl.config({
    input = {
        kb_layout  = "tr",        -- sistem klavyesi (localectl: tr / pc105)
        kb_model   = "pc105",
        kb_options = "",
        numlock_by_default = true,

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,  -- KDE'de açık (kcminputrc)
            tap_to_click   = true,
            clickfinger_behavior = true,
            scroll_factor  = 1.0,
        },
    },
})

-- 3 parmak yatay kaydırma -> çalışma alanı değiştir
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up",   action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "down", action = "close" })
