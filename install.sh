sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
../
yay -S rofi otf-font-awesome ttf-jetbrains-mono  hyper  zsh  bluez bluez-utils blueman visual-studio-code-bin alacritty pavucontrol waybar hyprpaper hyprshot  nwg-look-bin nautilus hyprshot unzip brightnessctl xsensors
cp -r rofi/ hypr/ waybar/ alacritty/ ~/.config/
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git && ./Fluent-gtk-theme/install.sh
rm -rf ./Fluent-gtk-theme
sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
sudo cp -r ./etc/* /etc/ 
