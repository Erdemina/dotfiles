cp -r rofi/ hypr/ waybar/ alacritty/ ~/.config/
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -S rofi visual-studio-code-bin alacritty nautilus pavucontrol waybar hyprpaper hyprshot wlogout nwg-look-bin nautilus hyprshot unzip brightnessctl xsensors
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git && ./Fluent-gtk-theme/install.sh
rm -rf ./Fluent-gtk-theme
git clone https://aur.archlinux.org/sddm-theme-tokyo-night.git && cd sddm-theme-tokyo-night && makepkg -Ccsi
cd ../ && rm -rf sddm-theme-tokyo-night
sudo cp -r ./etc/* /etc/ 
