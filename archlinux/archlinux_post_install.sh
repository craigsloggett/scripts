#!/bin/bash

#########################################################
# Arch Linux Post Install Script
#
# This script is intended to install and configure 
# applications required for an i3 X.Org desktop 
# environment.
#
# Created February 9th, 2017 by nerditup
#########################################################

#########################################################
# Configuration Variables
#########################################################

virtualbox='false';

# Personal
username='nerditup';

#########################################################
# Useful Functions
#########################################################

install_AUR_package() {
    cd /home/"$username"/Source/AUR
    git clone https://aur.archlinux.org/"$1".git
    cd "$1"
    makepkg -si --noconfirm
}

clone_dotfiles() {
    mkdir -p /home/"$username"/Source/GitHub/nerditup
    cd /home/"$username"/Source/GitHub/nerditup
    git clone https://github.com/nerditup/dotfiles
}

symlink_dotfiles() {
    cd /home/"$username"/Source/GitHub/nerditup/dotfiles;
    for d in "$(ls --ignore=README* .)";
    do
        ( stow --verbose --target=/home/"$username" $d );
    done
}

setup_virtualbox() {
    touch /tmp/virtualbox.conf_new;
    echo 'vboxguest' >> /tmp/virtualbox.conf_new;
    echo 'vboxsf' >> /tmp/virtualbox.conf_new;
    echo 'vboxvideo' >> /tmp/virtualbox.conf_new;
    sudo cp /tmp/virtualbox.conf_new /etc/modules-load.d/virtualbox.conf
    rm /tmp/virtualbox.conf_new
}

# Export XDG Base User Directory Environment Variables
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

# Setup XDG Base User Directory Structure
mkdir -p "${XDG_CONFIG_HOME}"
mkdir -p "${XDG_CACHE_HOME}"
mkdir -p "${XDG_DATA_HOME}"

# TODO: Iterate over a list of files and ensure they exist before attempting to move them.
# BASH XDG Specification
mkdir -p "${XDG_CONFIG_HOME}"/bash
mkdir -p "${XDG_DATA_HOME}"/bash
mv /home/"$username"/.bashrc "${XDG_CONFIG_HOME}"/bash/bashrc
mv /home/"$username"/.bash_profile "${XDG_CONFIG_HOME}"/bash/profile
mv /home/"$username"/.bash_logout "${XDG_CONFIG_HOME}"/bash/logout
mv /home/"$username"/.bash_history "${XDG_DATA_HOME}"/bash/history
export HISTFILE="${XDG_DATA_HOME}"/bash/history

# Setup Home Directory
mkdir -p /home/"$username"/Source
mkdir -p /home/"$username"/Downloads
mkdir -p /home/"$username"/Wallpaper
mkdir -p /home/"$username"/Source/AUR
mkdir -p /home/"$username"/Source/GitHub
mkdir -p /home/"$username"/.config
mkdir -p /home/"$username"/.local
mkdir -p /home/"$username"/.local/share

# Install Preferred Terminal Applications
sudo pacman -S --noconfirm vim
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm stow  # Manage Dotfiles

# Install Xorg
sudo pacman -S --noconfirm xorg-server

# Install a Desktop Environment
sudo pacman -S --noconfirm i3-gaps          # Window Manager
sudo pacman -S --noconfirm rxvt-unicode     # Terminal Emulator
sudo pacman -S --noconfirm compton          # Xorg Compositor
sudo pacman -S --noconfirm rofi             # Application Launcher
sudo pacman -S --noconfirm dunst            # Notifications
sudo pacman -S --noconfirm udiskie          # Automount Removable Media
sudo pacman -S --noconfirm feh              # Manage Wallpapers
sudo pacman -S --noconfirm autocutsel       # Synchronize PRIMARY copy/paste buffer with CLIPBOARD

# Fonts, etc.
sudo pacman -S --noconfirm ttf-dejavu
sudo pacman -S --noconfirm ttf-liberation

# VirtualBox or Physical
if [ "$virtualbox" = true ]
then { 
    # Install VirtualBox Guest Additions (Arch Modules)
    (echo 2; echo Y;) | sudo pacman -S virtualbox-guest-utils
    sudo setup_virtualbox
}
else
    # Install Light Backlight Manager
    sudo pacman -S --noconfirm light
    sudo pacman -S --noconfirm xbindkeys
fi

# Clone Configuration Files from GitHub
clone_dotfiles
symlink_dotfiles

echo 'Configuration Completed.';
