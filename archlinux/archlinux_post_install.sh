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

#########################################################
# Configuration Variables
#########################################################

virtualbox=false;
username='nerditup';
zone='Canada';
subzone='Eastern';

#########################################################
# Useful Functions
#########################################################

install_AUR_package() {
    cd ~
    cd Source/AUR
    git clone https://aur.archlinux.org/$1.git
    cd $1
    makepkg -si --noconfirm
}

clone_dotfiles() {
    cd ~
    mkdir -p Source/GitHub/nerditup
    cd Source/GitHub/nerditup
    git clone https://github.com/nerditup/dotfiles
}

configure_default_shell() {
    usermod -s /bin/zsh "$username";
    usermod -s /bin/zsh root;
}

configure_timezone() {
    timedatectl set-timezone "$zone/$subzone";
}

symlink_dotfiles() {
    cd ~
    # Symlink dotfiles using Stow.
    (echo ;) | rm .xinitrc;  # Remove conflicting file
    cd Source/GitHub/nerditup/dotfiles;
    for d in $(ls --ignore=README* .);
    do
        ( stow --verbose --target=~ $d );
    done
}

setup_virtualbox() {
    # Load the VirtualBox kernel modules at boot
    touch virtualbox.conf_new;
    echo 'vboxguest' >> virtualbox.conf_new;
    echo 'vboxsf' >> virtualbox.conf_new;
    echo 'vboxvideo' >> virtualbox.conf_new;
    cp virtualbox.conf_new /etc/modules-load.d/virtualbox.conf
    rm virtualbox.conf_new
}

# Set the Local Timezone
configure_timezone

# Setup Home Directory
cd ~
mkdir -p Source
mkdir -p Downloads
mkdir -p Wallpaper
mkdir -p Source/AUR
mkdir -p Source/GitHub
mkdir -p .config
mkdir -p .local
mkdir -p .local/share

# Install Preferred Terminal Applications
pacman -S --noconfirm zsh
pacman -S --noconfirm git
pacman -S --noconfirm stow  # Manage Dotfiles

# Install Xorg
pacman -S --noconfirm xorg-server xorg-xinit xorg-xsetroot xorg-xprop
cp -v /etc/X11/xinit/xinitrc /home/$username/.xinitrc;

# Install a Desktop Environment
#pacman -S --noconfirm bspwm           # Window Manager
#pacman -S --noconfirm sxhkd           # Window Manager Hot Keys
#install_AUR_package lemonbar-xft-git  # Status Bar
pacman -S --noconfirm rxvt-unicode     # Terminal Emulator
pacman -S --noconfirm compton          # Xorg Compositor
pacman -S --noconfirm rofi             # Application Launcher
pacman -S --noconfirm dunst            # Notifications
pacman -S --noconfirm udiskie          # Automount Removable Media
pacman -S --noconfirm feh              # Manage Wallpapers
pacman -S --noconfirm autocutsel       # Synchronize PRIMARY copy/paste buffer with CLIPBOARD

# Fonts, etc.
pacman -S --noconfirm ttf-dejavu
pacman -S --noconfirm ttf-liberation

# VirtualBox or Physical
if [ "$virtualbox" = true ]
then { 
    # Install VirtualBox Guest Additions (Arch Modules)
    (echo 2; echo Y;) | pacman -S virtualbox-guest-utils
    setup_virtualbox
}
else
    # Install Light Backlight Manager
    install_AUR_package light-git
    pacman -S --noconfirm xbindkeys
fi

# Clone Configuration Files from GitHub
clone_dotfiles
symlink_dotfiles

# Configure the Default Shell for Root and Non-root User
configure_default_shell

echo 'Configuration Completed.';
