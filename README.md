# dotfiles — Hyprland alongside KDE Plasma (CachyOS)

[🇹🇷 Türkçe](README.tr.md)

A second desktop for CachyOS / Arch machines that already run **KDE Plasma**.
You keep Plasma exactly as it is and get a full **Hyprland** session next to it —
both selectable from the login screen, both sharing the same wallpaper, cursor,
theme and the KDE apps you already use.

```
┌ login screen ──────────────┐
│  Plasma (Wayland)  ←  untouched
│  Hyprland          ←  this repo
└────────────────────────────┘
```

## What you get

| Piece | Choice | Why |
|---|---|---|
| Compositor | **Hyprland 0.56+** (Lua config, `.conf` is deprecated) | modular `hypr/*.lua` |
| Wallpaper | **synced with KDE** | `hypr/scripts/wallpaper.sh` reads Plasma's config; changing it in Hyprland writes back to Plasma desktop + lock screen |
| Bar | waybar | workspaces, media, weather, cpu/mem/temp, net, battery, audio, tray, power |
| Launcher | rofi 2 (native Wayland) | single `Meta` press, like Plasma |
| Terminal | ghostty | Catppuccin Mocha, 78% opacity + blur, Konsole-style tab/split keys |
| Lock / idle | hyprlock + hypridle | lock screen uses the KDE wallpaper too |
| Notifications | mako | |
| Clipboard | cliphist | `Meta+V`, like Klipper |
| Screenshots | **Spectacle** (via xdg-desktop-portal-hyprland), hyprshot as fallback | |
| Files / auth / tray | Dolphin, polkit-kde-agent, KDE Connect, nm-applet, blueman | |
| Qt theming | `QT_QPA_PLATFORMTHEME=kde` | Qt apps read your `kdeglobals` → Breeze Dark, icons, fonts identical to Plasma |
| Secrets | Secret portal → **KWallet** (`xdg-desktop-portal/hyprland-portals.conf`) | Chromium-based browsers keep their cookies/passwords — no re-login when switching from Plasma |
| Settings | `Meta+I` rofi menu (`hypr/scripts/settings.sh`) | wallpaper, border colour, gaps, blur, animations, keyboard layout, power profile, edit configs, sync to dotfiles |

Look: blue→sky gradient borders, 12px gaps, rounding 10, light blur.

## Install

```sh
git clone https://github.com/Erdemina/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh            # packages (sudo) + copies configs into ~/.config
```

Options: `--link` (symlink instead of copy, repo stays the source of truth),
`--no-pkgs` (skip pacman), `--dry-run`.

The installer backs up anything it replaces to `~/.config/<name>.bak-<timestamp>`,
picks your keyboard layout from `localectl`, seeds the wallpaper from Plasma and
runs `Hyprland --verify-config`. Reboot, choose **Hyprland** on the login screen.

### Requirements
CachyOS or Arch, KDE Plasma 6 installed, Wayland. Hyprland ≥ 0.55 (Lua config).

## Keybindings

Priority: custom shortcuts from my KDE setup → KDE defaults → old dotfiles.

| Keys | Action |
|---|---|
| `Meta+Q` / `Meta+Enter` | terminal |
| `Meta` (tap) / `Meta+R` | app launcher |
| `Meta+E` | Dolphin |
| `Meta+C` / `Alt+F4` | close window |
| `Meta+F` | fullscreen · `Meta+PgUp` maximize · `Meta+PgDn` minimize to scratchpad |
| `Meta+1..0` / `Meta+Shift+1..0` | go to / move to workspace · `Meta+Ctrl+←/→` prev/next |
| `Meta+←↑↓→` / `+Shift` / `+Ctrl+Shift` | focus / move / resize |
| `Alt+Tab`, `Meta+Tab` | cycle windows |
| `Meta+V` | clipboard history · `Meta+Shift+V` toggle floating |
| `Meta+S` / `Meta+Alt+S` | scratchpad show / send · `Meta+Shift+S` region screenshot → clipboard |
| `Meta+G` | tabbed group · `Meta+P` pseudotile · `Meta+J` toggle split · `Meta+Shift+P` pin |
| `Print` / `Meta+Shift+Print` / `Meta+Print` | Spectacle full / region / window · `Meta+Shift+W` hyprshot region |
| `Meta+L` | lock · `Meta+M`, `Ctrl+Alt+Del` power menu |
| `Meta+I` | settings menu · `Meta+Shift+B` wallpaper picker (syncs to KDE) · `Meta+Shift+N` dismiss notifications |
| 3-finger swipe | workspaces (horizontal), fullscreen (up), close (down) |

`hyprctl binds` lists everything with descriptions.

## Wallpaper sync — how it works

Plasma is the single source of truth. `hypr/scripts/wallpaper.sh`:

- `current` — reads the desktop containment's `Image` from `plasma-org.kde.plasma.desktop-appletsrc`
- `apply` — run at Hyprland start: writes `hyprpaper.conf` + `wallpaper.conf` (for hyprlock) and starts hyprpaper
- `set <file>` — writes Plasma desktop (`plasma-apply-wallpaperimage` if Plasma is running, else `kwriteconfig6`) + lock screen, then hyprpaper
- `pick` — rofi picker over `~/Pictures/Wallpapers` and `/usr/share/wallpapers/cachyos-wallpapers`

Change the wallpaper in Plasma → Hyprland picks it up on next login. Change it in Hyprland → Plasma has it immediately.

## Layout

```
hypr/         hyprland.lua (entry) → monitors, environment, input, lookandfeel, rules, keybinds, autostart
              hyprlock.conf, hypridle.conf, scripts/{wallpaper,powermenu}.sh
waybar/       config, style.css, mediaplayer.py, modules/
rofi/  ghostty/  mako/
autostart/    blueman.desktop with NotShowIn=KDE (no duplicate tray icon in Plasma)
xdg-desktop-portal/  hyprland-portals.conf — Secret → kwallet, FileChooser → kde
install.sh
```

Things you may want to edit: `hypr/monitors.lua` (my laptop panel is eDP-1 1920×1200; the empty-output rule covers everything else),
`waybar/config` weather city, `hypr/keybinds.lua` terminal.

## Credits
Old config this grew from: my previous Hyprland dotfiles (hyprlang era). Hyprland wiki for the Lua API.
