-- Açılışta çalışacaklar
local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.on("hyprland.start", function()
    -- Portal: KDE oturumundan kalan portal yerine Hyprland portalını kullan (Spectacle, ekran paylaşımı)
    hl.exec_cmd("sleep 1; systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")

    hl.exec_cmd(scripts .. "/wallpaper.sh apply")          -- KDE'deki duvar kağıdı → hyprpaper
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")  -- KDE'nin yetki penceresi
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
