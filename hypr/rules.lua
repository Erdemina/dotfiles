-- Pencere kuralları: https://wiki.hypr.land/Configuring/Core/Rules/Window-Rules/

-- Uygulamaların "maximize" isteklerini yoksay (tiling düzenini bozmasın)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- XWayland sürükleme sorunlarını düzelt
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Sistem araçları: yüzen, ortalanmış
local floating = {
    "^(pavucontrol)$", "^(org\\.pulseaudio\\.pavucontrol)$",
    "^(nm-connection-editor)$", "^(blueman-manager)$",
    "^(org\\.kde\\.polkit-kde-authentication-agent-1)$",
    "^(xdg-desktop-portal-gtk)$", "^(xdg-desktop-portal-kde)$",
    "^(org\\.kde\\.kdeconnect.*)$",
    "^(xsensors)$",
}
for _, c in ipairs(floating) do
    hl.window_rule({ match = { class = c }, float = true, center = true })
end

-- Spectacle: yüzen ve ortalanmış, ekran görüntüsünde kendisi görünmesin
hl.window_rule({ match = { class = "^(org\\.kde\\.spectacle)$" }, float = true, center = true })

-- Dosya seçici diyalogları
hl.window_rule({ match = { title = "^(Open File|Save File|Dosya Aç|Dosyayı Kaydet|Select a File|Choose Files).*" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.6" } })

-- Tam ekran içerik varken uyku moduna geçme
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "fullscreen" })

-- Video/oyun içerikli pencerelerde blur kapalı
hl.window_rule({ match = { class = "^(mpv|vlc)$" }, no_blur = true })

-- Duvar kağıdı / kenarlık rengi seçicileri: ortada yüzen pencere (boyut pencerenin kendisinden)
hl.window_rule({ match = { class = "^(hypr\\.(wallpaper|border)-picker)$" }, float = true, center = true })

-- hyprland-run (hyprland-guiutils) küçük çalıştırıcı
hl.window_rule({ match = { class = "hyprland-run" }, move = { "20", "monitor_h-120" }, float = true })

-- Katman kuralları: bildirim ve launcher animasyonları hızlı
hl.layer_rule({ match = { namespace = "^(rofi)$" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "^(notifications)$" }, blur = true, ignore_alpha = 0.5 })
