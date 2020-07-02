#!/bin/bash

#########################################################
# Void Linux Install Script
#
# This script is intended to automate the install process
# and setup configuration of Void Linux.
#
# Created March 6th, 2020 by nerditup
#########################################################

# Hardware
disk='nvme0n1';
partition='p';
rootfs='xfs';

# Personal
hostname='io';

# Repository URL
repo_url='https://mirror.clarkson.edu/voidlinux/current/musl'

# Format the Hard Disk
format_disk() {
    # Boot Partition
    mkfs.fat -F 32 /dev/"$disk""$partition"1;

    # Root Partition
    mkfs."$rootfs" /dev/"$disk""$partition"2;
}

# Mount the Partitions
mount_partitions() {
    # Root Partition
    mount /dev/"$disk""$partition"2 /mnt;

    # Boot Partition
    mkdir /mnt/boot;  # Create a boot directory to mount to.
    mount /dev/"$disk""$partition"1 /mnt/boot;

    mkdir /mnt/dev /mnt/proc /mnt/sys
    mount --rbind /dev /mnt/dev
    mount --rbind /proc /mnt/proc
    mount --rbind /sys /mnt/sys

    # Ensure the following directory structure exists:
    # /boot/EFI/BOOT/foo.efi
    # /boot/{vmlinuz-linux, initramfs-linux.img}
    #
    # EFI entries won't show up in the firmware if no file exists in esp/EFI/BOOT/foo.efi
    # the dell bios expects to find /EFI/boot/bootx64.efi

    mkdir -p /mnt/boot/EFI/boot
    mkdir -p /mnt/boot/EFI/Linux
}

# Disk Setup
format_disk        # Format the Hard Disk
mount_partitions   # Mount the Partitions

# Copy the EFI STUB image to the boot directory.
scp nerditup@jupiter.nerditup.ca:/home/nerditup/linuxx64.efi.stub /mnt/boot/EFI/Linux/

# Install Packages
export XBPS_ARCH=x86_64-musl
xbps-install -S -R "${repo_url}" -r /mnt base-system

# Install intel-ucode
# `xbps-install -S void-repo-nonfree`
# `xbps-install -S intel-ucode`
# ... the linux image is built with the microcode in it, no more work necessary.
# Generate fstab
# Change root password
# Copy EFI STUB image
# Generate EFI kernel
# Change shell for root
# Set the local timezone `ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime`
# Setup NTP
# Set XDG base system profile variables
# Create XDG folders in /root
# Copy XDG bash profile variables
# Setup bash XDG directories in home
# Copy XDG less to profile
# Setup less XDG directories in home
# Copy XDG zsh to profile
# Install zsh
# Copy XDG zprofile zshenv
# Setup zsh XDG directories in home
# Copy zsh dotfiles to home
# Change root shell to zsh
# Install vim
# Copy XDG vim profile
# Setup vim XDG directories in home
# Copy vim dotfiles to home
# Setup wireless
# `wpa_passphrase "SSID" >> /etc/wpa_supplicant/wpa_supplicant-wlp58s0.conf`
# `ln -s /etc/sv/`
# Create new user
# Create XDG folders in /home for user
# Configure FQDN
# Configure ssh key
# Install gpg
# Copy gpg configuration to ~/.local/share/gnupg (has to be next to data)
# Import master gpg key
# Configure pass
# Clone pass store to ~/.local/share/pass
# Configure git (username, email)

# Setup xbps-src
# Install curl
# `sudo xbps-install xtools`
# Clone void-packages git repository
# `mkdir -p ~/src/github.com/void-linux/`
# `cd ~/src/github.com/void-linux/`
# `git clone git://github.com/void-linux/void-packages.git`

# Configure X11
# `sudo xbps-install xorg-minimal`


# ... automate building the kernel when updating
