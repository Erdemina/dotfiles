-- Görünüm: eski dotfiles'taki turuncu→sarı gradient ve boşluklar korundu
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(ff492aee)", "rgba(ffd72aee)" }, angle = 30 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a },
        blur   = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },
    master  = { new_status = "master" },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        focus_on_activate       = true,
    },

    ecosystem = { no_update_news = true, no_donation_nag = true },

    -- Grup çubuğu (Meta+G ile sekmeli pencere grubu)
    group = {
        col = {
            border_active   = { colors = { "rgba(ff492aee)", "rgba(ffd72aee)" }, angle = 30 },
            border_inactive = "rgba(595959aa)",
        },
        groupbar = { font_size = 10, gradients = false },
    },
})

-- Animasyon eğrileri
hl.curve("myBezier",     { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1}   } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},      {1, 1}      } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},  {0.75, 1}   } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}    } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 7,    bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 7,    bezier = "default",      style = "popin 80%" })
hl.animation({ leaf = "border",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "fade",          enabled = true, speed = 7,    bezier = "default" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 6,    bezier = "default",      style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })
