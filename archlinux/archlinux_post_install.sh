#!/bin/bash
#########################################################
# Arch Linux Post Install Script
#
# This script is intended to install and configure 
# applications required for an i3 X.Org desktop 
# environment.
#
# Made in 2017 by nerditup
# Last update in October, 2018
#########################################################

# Options
virtualbox=false;
username='nerditup';
zone='Canada';
subzone='Eastern';

# Script Functions
install_AUR_package() {
    echo ' Installing a package from the AUR'
    cd /home/$username/Source/AUR
    git clone https://aur.archlinux.org/$1.git
    cd $1
    makepkg -si --noconfirm
}

clone_configuration_files() {
    echo ' Cloning Configuration from GitHub...'
    mkdir -p /home/$username/Source/GitHub/nerditup
    cd /home/$username/Source/GitHub/nerditup
    git clone https://github.com/nerditup/scripts
    git clone https://github.com/nerditup/dotfiles
}

configure_default_shell() {
    echo ' Setting the default shell for '"$username"' to zsh...';
    sudo usermod -s /bin/zsh "$username";
    echo ' Setting the default shell for root to zsh...';
    sudo usermod -s /bin/zsh root;
}

configure_timezone() {
    echo ' Configuring the Timezone...';
    timedatectl set-timezone "$zone/$subzone";
    timedatectl status;
}

symlink_dotfiles() {
    # Symlink the Dotfiles with Stow
    (echo ;) | rm /home/$username/.xinitrc;             # Remove conflicting file
    cd /home/$username/Source/GitHub/nerditup/dotfiles; # Switch to the dotfiles directory
    for d in `ls --ignore=README* .`;
    do
        ( stow --verbose --target=/home/$username $d );
    done
}

setup_virtualbox() {
    echo ' Installing VirtualBox Guest Additions...';
    # Load the VirtualBox kernel modules at boot
    echo ' Make the VirtualBox Guest Additions kernel modules load at boot...';
    touch virtualbox.conf_new;
    echo 'vboxguest' >> virtualbox.conf_new;
    echo 'vboxsf' >> virtualbox.conf_new;
    echo 'vboxvideo' >> virtualbox.conf_new;
    sudo cp virtualbox.conf_new /etc/modules-load.d/virtualbox.conf
    rm virtualbox.conf_new

    if [ "$debug" = true ]
    then { 
        echo " Completed VirtualBox Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo " Completed VirtualBox Configuration.";
    fi
}

# Set the Local Timezone
configure_timezone

# Setup Home Directory
mkdir -p /home/$username/Source
mkdir -p /home/$username/Downloads
mkdir -p /home/$username/Wallpaper
mkdir -p /home/$username/Source/AUR
mkdir -p /home/$username/Source/GitHub
mkdir -p /home/$username/.config
mkdir -p /home/$username/.local
mkdir -p /home/$username/.local/share

# Install Preferred Terminal Applications
sudo pacman -S --noconfirm zsh
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm stow  # Manage Dotfiles

# Install Xorg
sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xsetroot xorg-xprop
cp -v /etc/X11/xinit/xinitrc /home/$username/.xinitrc;

# Install a Desktop Environment
sudo pacman -S --noconfirm bspwm            # Window Manager
sudo pacman -S --noconfirm sxhkd            # Window Manager Hot Keys
sudo pacman -S --noconfirm rxvt-unicode     # Terminal Emulator
sudo pacman -S --noconfirm compton          # Xorg Compositor
sudo pacman -S --noconfirm rofi             # Application Launcher
sudo pacman -S --noconfirm dunst            # Notifications
sudo pacman -S --noconfirm udiskie          # Automount Removable Media
sudo pacman -S --noconfirm feh              # Manage Wallpapers
sudo pacman -S --noconfirm autocutsel       # Synchronize PRIMARY copy/paste buffer with CLIPBOARD
install_AUR_package lemonbar-xft-git        # Status Bar

# Fonts, etc.
sudo pacman -S --noconfirm ttf-dejavu
sudo pacman -S --noconfirm ttf-liberation

# VirtualBox or Physical
if [ "$virtualbox" = true ]
then { 
    # Install VirtualBox Guest Additions (Arch Modules)
    (echo 2; echo Y;) | sudo pacman -S virtualbox-guest-utils
    setup_virtualbox
}
else
    # Install Light Backlight Manager
    install_AUR_package light-git
    sudo pacman -S --noconfirm xbindkeys
fi

# Clone Configuration Files from GitHub
clone_configuration_files
symlink_dotfiles

# Configure the Default Shell for Root and Non-root User
configure_default_shell

echo 'Configuration Completed.';
