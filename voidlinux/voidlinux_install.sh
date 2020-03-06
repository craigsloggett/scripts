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
hostname='VoidBox';

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
}

# Disk Setup
format_disk        # Format the Hard Disk
mount_partitions   # Mount the Partitions

# Install Packages
export XBPS_ARCH=x86_64-musl
xbps-install -S -R "${repo_url}" -r /mnt base-system grub-x86_64-efi
