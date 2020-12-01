#!/bin/sh -e

# Hardware
disk='sda';
partition='';
rootfs='ext4';

# KISS
release='2020.9-2';

# Partition the Hard Disk
partition_disk() {
    # Boot Partition
    parted -s /dev/"$disk" mklabel gpt;
    parted -s /dev/"$disk" mkpart primary 1MiB 257MiB;
    parted -s /dev/"$disk" set 1 esp on;

    # Root Partition
    parted -s /dev/"$disk" mkpart primary 257MiB 100%;
}

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
}

# Disk Setup
partition_disk    # Partition the Hard Disk
format_disk       # Format the Hard Disk
mount_partitions  # Mount the Partitions

# Download the Latest Release
url="https://github.com/kisslinux/repo/releases/download/$release"
tar="kiss-chroot-$release.tar.xz"

wget -O "$HOME/$tar" "$url/$tar"

cd /mnt
tar xvf "$HOME/$tar"

# TODO: Setup the chroot manually and continue installation from this disk.
