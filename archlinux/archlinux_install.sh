#!/bin/zsh

#########################################################
# Arch Linux Install Script
#
# This script is intended to automate the install process
# and setup configuration of Arch Linux.
#
# Created February 9th, 2017 by nerditup
#########################################################

#########################################################
# Configuration Variables
#########################################################

virtualbox='false';  # Setup the VirtualBox Guest Additions
debug='false';       # Require user input to proceed

# Hardware
disk='nvme0n1';      # Dell XPS Hard Disk
partition='p';       # Dell XPS Partition Prefix
network='wlp58s0';   # Dell XPS Network Interface
bootfs='vfat';
rootfs='ext4';

# Region
country='CA';
locale='en_'"$country"'.UTF-8';

# Personal
hostname='ArchBox';
password='testpass';
username='nerditup';

#########################################################
# Useful Functions
#########################################################

# Partition the Hard Disk
partition_disk() {
    # Boot Partition
    parted -s /dev/sda mklabel gpt;
    parted -s /dev/sda mkpart primary fat32 1MiB 513MiB;
    parted -s /dev/sda set 1 esp on;
    
    # Root Partition
    parted -s /dev/sda mkpart primary 513MiB 100%;
}

# Format the Hard Disk
format_disk() {
    # Boot Partition
    mkfs."$bootfs" -F 32 /dev/"$disk""$partition"1;

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

# Sort the Mirror List by Location and Availability (Putting the Closest at the Top)
sort_mirror_list() {
    # Generate the mirror URL and a temp file for sorting.
    url='https://www.archlinux.org/mirrorlist/?country='"$country"'&protocol=https&ip_version=4&use_mirror_status=on';
    tmpfile=$(mktemp --suffix=-mirrorlist);

    # Get latest mirror list and save to tmpfile
    echo 'Downloading the latest mirrorlist...';
    wget -qO- "$url" | sed 's/^#Server/Server/g' > "$tmpfile"

    # Backup and replace current mirrorlist file (if new file is non-zero)
    if [ -s "$tmpfile" ]
    then { 
        echo 'Backing up the original mirrorlist...'
        mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; 
    } && { 
        echo 'Rotating the new list into place...'
        mv -i "$tmpfile" /etc/pacman.d/mirrorlist; 
    }
    else
        echo 'Unable to update, could not download list.'
    fi
}

# Configure the fstab File
configure_fstab() {
    genfstab -U -p /mnt >> /mnt/etc/fstab;
}

# Configure the System Locale
configure_locale() {
    # Create the locale configuration file.
    touch locale.conf_new
    echo 'LANG='"$locale" > locale.conf_new;
    export LANG="$locale";

    # Copy the locale configuration file to the new system.
    cp locale.conf_new /mnt/etc/locale.conf
    rm locale.conf_new

    # Create a backup of the current locale.gen file
    cp /mnt/etc/locale.gen /mnt/etc/locale.gen_bak;

    # Remove the leading # to uncomment the desired locale
    sed 's/#'"$locale"'/'"$locale"'/g' /mnt/etc/locale.gen_bak > /mnt/etc/locale.gen;
    rm /mnt/etc/locale.gen_bak;

    # Generate the locale for the new system.
    arch-chroot /mnt locale-gen;
    arch-chroot /mnt locale -a;
}

# Configure the Hostname
configure_hostname() {
    echo "$hostname" > /mnt/etc/hostname;
}

# Configure the Network
configure_network() {
    arch-chroot /mnt systemctl enable systemd-networkd.service;
    arch-chroot /mnt systemctl enable systemd-resolved.service;
    echo "[Match]" > /mnt/etc/systemd/network/25-wireless.network
    echo "Name=$network" >> /mnt/etc/systemd/network/25-wireless.network
    echo "" >> /mnt/etc/systemd/network/25-wireless.network
    echo "[Network]" >> /mnt/etc/systemd/network/25-wireless.network
    echo "DHCP=ipv4" >> /mnt/etc/systemd/network/25-wireless.network
}

# Configure the Non-Root User
configure_user() {
    arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $username;
    (echo "$password"; echo "$password";) | arch-chroot /mnt passwd $username;
}

# Configure the Bootloader
configure_bootloader() {
    arch-chroot /mnt bootctl --path=/boot install;

    # Configure bootctl
    mkdir -p /mnt/boot/loader;
    mkdir -p /mnt/boot/loader/entries;
    cp -v /mnt/usr/share/systemd/bootctl/loader.conf /mnt/boot/loader/loader.conf;
    echo 'timeout 4' >> /mnt/boot/loader/loader.conf;
    echo 'editor  0' >> /mnt/boot/loader/loader.conf;
    echo 'title     Arch Linux' > /mnt/boot/loader/entries/arch.conf;
    echo 'linux     /vmlinuz-linux' >> /mnt/boot/loader/entries/arch.conf;

    # Setup Intel microcode updates?
    if [ "$virtualbox" = true ]
    then { 
        : # No need to setup Intel Microcode updates.
    }
    else
        # Setup Intel microcode updates.
        echo 'initrd    /intel-ucode.img' >> /mnt/boot/loader/entries/arch.conf;
    fi

    # Linux initramfs must go after any microcode updates.
    echo 'initrd    /initramfs-linux.img' >> /mnt/boot/loader/entries/arch.conf;
    echo 'options   root=/dev/'"$disk""$partition"'2 rw' >> /mnt/boot/loader/entries/arch.conf;
    
    # Update the bootloader
    arch-chroot /mnt bootctl update;
}

# Set the Root Password
set_root_password() {
    (echo "$password"; echo "$password";) | arch-chroot /mnt passwd;
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
partition_disk     # Partition the Hard Disk
format_disk        # Format the Hard Disk
mount_partitions   # Mount the Partitions

status_update 'Disk';

# Mirror Selection
sort_mirror_list;  # Sort the Mirror List by Location and Availability

# Install Packages
pacstrap /mnt base;
pacstrap /mnt base-devel;

status_update 'Packages';

# Configure the System
configure_fstab         # Configure the fstab File
configure_locale        # Configure the system locale
configure_hostname      # Configure the Hostname
configure_network       # Configure the Network
configure_user          # Configure the Non-root User
configure_bootloader    # Configure the EFI Bootloader

status_update 'System';

# VirtualBox or Physical
if [ "$virtualbox" = true ]
then { 
    :
}
else
    # Setup Dell XPS Related Modules
    pacstrap /mnt iw wpa_supplicant;        # WiFi connections
    pacstrap /mnt intel-ucode;              # Intel Microcode 
fi

# Root
set_root_password       # Set the root password

status_update 'Root Password';

echo 'Installation Completed. Please Restart the Machine.';
