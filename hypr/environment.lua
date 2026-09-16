-- Ortam değişkenleri: https://wiki.hypr.land/Configuring/Core/Environment-variables/

-- İmleç: KDE'deki ile aynı (capitaine-cursors, 24px)
hl.env("XCURSOR_THEME", "capitaine-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt uygulamaları (Dolphin, Konsole, Spectacle...) KDE'nin kdeglobals temasını
-- (Breeze Dark, ikonlar, fontlar) aynen kullansın
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- GTK / diğer
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Oturum kimliği (portal seçimi ve uygulama menüleri için)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
