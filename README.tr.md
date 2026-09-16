# dotfiles — KDE Plasma'nın yanına Hyprland (CachyOS)

[🇬🇧 English](README.md)

Zaten **KDE Plasma** kullanan CachyOS / Arch makineler için ikinci bir masaüstü.
Plasma'ya hiç dokunmadan yanına tam bir **Hyprland** oturumu gelir — ikisi de
giriş ekranından seçilir, aynı duvar kağıdını, imleci, temayı ve zaten kullandığın
KDE uygulamalarını paylaşır.

```
┌ giriş ekranı ──────────────┐
│  Plasma (Wayland)  ←  dokunulmadı
│  Hyprland          ←  bu repo
└────────────────────────────┘
```

## Neler var

| Parça | Seçim | Neden |
|---|---|---|
| Compositor | **Hyprland 0.56+** (Lua config, `.conf` artık deprecated) | modüler `hypr/*.lua` |
| Duvar kağıdı | **KDE ile senkron** | `hypr/scripts/wallpaper.sh` Plasma'nın config'ini okur; Hyprland'de değiştirince Plasma masaüstü + kilit ekranına da yazar |
| Çubuk | waybar | çalışma alanları, medya, hava, cpu/ram/sıcaklık, ağ, pil, ses, tepsi, güç |
| Başlatıcı | rofi 2 (yerel Wayland) | Plasma'daki gibi tek `Meta` |
| Terminal | ghostty | Catppuccin Mocha, 78% opacity + blur, Konsole-style tab/split keys |
| Kilit / boşta | hyprlock + hypridle | kilit ekranı da KDE duvar kağıdını kullanır |
| Bildirim | mako | |
| Pano | cliphist | Klipper gibi `Meta+V` |
| Ekran görüntüsü | **Spectacle** (xdg-desktop-portal-hyprland üzerinden), yedek hyprshot | |
| Dosya / yetki / tepsi | Dolphin, polkit-kde-agent, KDE Connect, nm-applet, blueman | |
| Qt teması | `QT_QPA_PLATFORMTHEME=kde` | Qt uygulamaları `kdeglobals`'ı okur → Breeze Dark, ikonlar, fontlar Plasma ile birebir |
| Gizli anahtarlar | Secret portal → **KWallet** (`xdg-desktop-portal/hyprland-portals.conf`) | Chromium tabanlı tarayıcılar çerez/parolalarını korur — Plasma'dan geçince tekrar giriş yok |
| Ayarlar | `Meta+I` rofi menüsü (`hypr/scripts/settings.sh`) | duvar kağıdı, kenarlık rengi, boşluk, blur, animasyon, klavye düzeni, güç profili, config düzenle, dotfiles'a kaydet |

Görünüm: mavi→gök mavisi gradient kenarlık, 12px boşluk, 10px yuvarlatma, hafif blur.

## Kurulum

```sh
git clone https://github.com/Erdemina/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh            # paketler (sudo) + config'leri ~/.config'e kopyalar
```

Seçenekler: `--link` (kopya yerine symlink, repo kaynak kalır),
`--no-pkgs` (pacman adımını atla), `--dry-run`.

Betik değiştirdiği her şeyi `~/.config/<ad>.bak-<zaman>` olarak yedekler,
klavye düzenini `localectl`'den alır, ilk duvar kağıdını Plasma'dan çeker ve
`Hyprland --verify-config` çalıştırır. Yeniden başlat, giriş ekranında **Hyprland**'i seç.

### Gereksinimler
CachyOS veya Arch, KDE Plasma 6 kurulu, Wayland. Hyprland ≥ 0.55 (Lua config).

## Kısayollar

Öncelik: kendi KDE kurulumumdaki özel kısayollar → KDE varsayılanları → eski dotfiles.

| Tuş | İşlev |
|---|---|
| `Meta+Q` / `Meta+Enter` | terminal |
| `Meta` (tek) / `Meta+R` | uygulama başlatıcı |
| `Meta+E` | Dolphin |
| `Meta+C` / `Alt+F4` | pencereyi kapat |
| `Meta+F` | tam ekran · `Meta+PgUp` büyüt · `Meta+PgDn` scratchpad'e küçült |
| `Meta+1..0` / `Meta+Shift+1..0` | çalışma alanına git / taşı · `Meta+Ctrl+←/→` önceki/sonraki |
| `Meta+←↑↓→` / `+Shift` / `+Ctrl+Shift` | odak / taşı / boyutlandır |
| `Alt+Tab`, `Meta+Tab` | pencereler arasında gez |
| `Meta+V` | pano geçmişi · `Meta+Shift+V` yüzen/döşeli |
| `Meta+S` / `Meta+Alt+S` | scratchpad göster / gönder · `Meta+Shift+S` bölge görüntüsü → pano |
| `Meta+G` | sekmeli grup · `Meta+P` pseudotile · `Meta+J` bölme yönü · `Meta+Shift+P` sabitle |
| `Print` / `Meta+Shift+Print` / `Meta+Print` | Spectacle tam / bölge / pencere · `Meta+Shift+W` hyprshot bölge |
| `Meta+L` | kilitle · `Meta+M`, `Ctrl+Alt+Del` güç menüsü |
| `Meta+I` | ayar menüsü · `Meta+Shift+B` duvar kağıdı seçici (KDE'ye de yazar) · `Meta+Shift+N` bildirimleri kapat |
| 3 parmak kaydırma | çalışma alanı (yatay), tam ekran (yukarı), kapat (aşağı) |

`hyprctl binds` hepsini açıklamalarıyla listeler.

## Duvar kağıdı senkronu nasıl çalışıyor

Tek kaynak Plasma. `hypr/scripts/wallpaper.sh`:

- `current` — `plasma-org.kde.plasma.desktop-appletsrc` içindeki masaüstü containment'ının `Image` değerini okur
- `apply` — Hyprland açılışında çalışır: `hyprpaper.conf` + `wallpaper.conf` (hyprlock için) yazar, hyprpaper'ı başlatır
- `set <dosya>` — Plasma masaüstü (Plasma çalışıyorsa `plasma-apply-wallpaperimage`, değilse `kwriteconfig6`) + kilit ekranı, sonra hyprpaper
- `pick` — `~/Pictures/Wallpapers` ve `/usr/share/wallpapers/cachyos-wallpapers` üzerinden rofi seçici

Plasma'da değiştir → Hyprland bir sonraki girişte alır. Hyprland'de değiştir → Plasma'da anında hazır.

## Dizin yapısı

```
hypr/         hyprland.lua (giriş) → monitors, environment, input, lookandfeel, rules, keybinds, autostart
              hyprlock.conf, hypridle.conf, scripts/{wallpaper,powermenu}.sh
waybar/       config, style.css, mediaplayer.py, modules/
rofi/  ghostty/  mako/
autostart/    NotShowIn=KDE'li blueman.desktop (Plasma'da çift tepsi simgesi olmasın)
xdg-desktop-portal/  hyprland-portals.conf — Secret → kwallet, FileChooser → kde
install.sh
```

Düzenlemek isteyebileceklerin: `hypr/monitors.lua` (benim laptop paneli eDP-1 1920×1200; boş output kuralı gerisini kapsar),
`waybar/config` hava durumu şehri, `hypr/keybinds.lua` terminal.

## Teşekkür
Bu config'in büyüdüğü eski Hyprland dotfiles'ım (hyprlang dönemi). Lua API için Hyprland wiki.
