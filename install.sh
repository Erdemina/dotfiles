sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
../
yay -S rofi otf-font-awesome ttf-jetbrains-mono  hyper  zsh  bluez bluez-utils blueman visual-studio-code-bin alacritty pavucontrol waybar hyprpaper hyprshot  nwg-look-bin nautilus hyprshot unzip brightnessctl xsensors
cp -r rofi/ hypr/ waybar/ alacritty/ ~/.config/
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git && ./Fluent-gtk-theme/install.sh
rm -rf ./Fluent-gtk-theme
git clone https://aur.archlinux.org/sddm-theme-tokyo-night.git && cd sddm-theme-tokyo-night && makepkg -Ccsi
cd ../ && rm -rf sddm-theme-tokyo-night
sudo cp -r ./etc/* /etc/ 
