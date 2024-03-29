sudo pacman -R pulse-native-provider

sudo pacman -S pulseaudio vlc waybar otf-font-awesome ttf-jetbrains-mono alacritty rofi nautilus hyprpaper git
sudo pacman -S pavucontrol unzip hyprshot brightnessctl mpd mpc xsensors
pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -S nwg-look-bin
yay -S visual-studio-code-bin
yay -S wlogout
yay -S xorg-xhost
xhost +SI:localuser:root
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git && ./Fluent-gtk-theme/install.sh
wget https://github.com/dracula/gtk/archive/master.zip && unzip -d ~/.themes/ master.zip && mv ~/.themes/gtk-master ~/.themes/Dracula &&  rm -rf master.zip
git clone https://aur.archlinux.org/sddm-theme-tokyo-night.git && cd sddm-theme-tokyo-night && makepkg -Ccsi
