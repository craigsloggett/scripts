#!/bin/sh -e

#########################################################
# KISS Linux Install Script
#
# This script is intended to automate the install process
# and setup configuration of KISS Linux.
#
# Created December 1st, 2020 by nerditup
#########################################################

#########################################################
# Configuration Variables
#########################################################

virtualbox='false';  # Setup the VirtualBox Guest Additions
debug='false';       # Require user input to proceed

# Hardware
disk='nvme0n1';
partition='p';
rootfs='ext4';

# Personal
hostname='xps';
username='nerditup';
password='testpass';

# KISS
release='2020.9-2';

#########################################################
# Useful Functions
#########################################################

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

# Configure the fstab File
configure_fstab() {
    genfstab -U /mnt >> /mnt/etc/fstab;
}

# Configure the Timezone
configure_timezone() {
    # TODO: Implement this.
}

# Configure the Timesync Service
configure_timesync() {
    # TODO: Implement this.
}

# Configure the Hostname
configure_hostname() {
    echo "$hostname" > /mnt/etc/hostname;
}

# Configure the Network
configure_network() {
    # TODO: Implement this.
}

# Configure the Non-Root User
configure_user() {
    # TODO: Implement this.
}

# Configure the Bootloader
configure_bootloader() {
    # TODO: Remove this, might not be necessary since using EFISTUB.
}

# Set the Root Password
set_root_password() {
    (echo "$password"; echo "$password";) | /mnt/bin/kiss-chroot /mnt passwd;
}

# Provide a Status Update
status_update() {
    if [ "$debug" = true ]
    then {
        echo "\nCompleted $1 Configuration, press any key to proceed...\n";
        read -n 1;
    }
    else
        echo "\nCompleted $1 Configuration.\n";
    fi
}

#########################################################
# Installation Procedure
#########################################################

# Disk Setup
partition_disk    # Partition the Hard Disk
format_disk       # Format the Hard Disk
mount_partitions  # Mount the Partitions

status_update 'Disk';

# Download the Latest Release
url="https://github.com/kisslinux/repo/releases/download/$release"
wget "$url/kiss-chroot-$release.tar.xz"

# Install Packages
# TODO: Determine which packages to install.

status_update 'Packages';

## Configure the System
#configure_fstab       # Configure the fstab File
#configure_timezone    # Configure the Timezone
#configure_timesync    # Configure the Timesync Service
#configure_hostname    # Configure the Hostname
#configure_network     # Configure the Network
#configure_user        # Configure the Non-root User
#configure_bootloader  # Configure the EFI Bootloader
#
#status_update 'System';
#
## VirtualBox or Physical
#if [ "$virtualbox" = true ]
#then {
#    :
#}
#else
#    # Setup Dell XPS Related Modules
#    # TODO: Implement this.
#fi
#
## Root
#set_root_password  # Set the root password
#
#status_update 'Root Password';

echo 'Installation Completed. Please Restart the Machine.';
