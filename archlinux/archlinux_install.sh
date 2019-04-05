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
swap='false';        # Setup a Swap partition
debug='false';       # Require user input to proceed

# Hardware
#disk='sda';         # VirtualBox Hard Disk
#partition='';       # VirtualBox Partition Prefix
disk='nvme0n1';      # Dell XPS Hard Disk
partition='p';       # Dell XPS Partition Prefix
network='wlp58s0';   # Dell XPS Network Interface
bootsize='512M';
swapsize='4G';
bootfs='fat';
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
    (echo g; echo n; echo 1; echo ; echo +"$bootsize";  # Boot Partition
     echo t; echo 1;                                    # Change the boot partition to type: EFI.
     echo w;) | fdisk /dev/"$disk";                     # Write the configuration to disk.

    if [ "$swap" = true ]
    then { 
        # Create the disk partitions with swap.
        (echo n; echo 2; echo ; echo +"$swapsize";  # Swap Partition
         echo n; echo 3; echo ; echo ;              # Root Partition
         echo t; echo 2; echo 19;                   # Change the swap partition to type: Linux Swap.
         echo w;) | fdisk /dev/"$disk";             # Write the configuration to disk.
    }
    else
        # Create the disk partitions without swap.
        (echo n; echo 2; echo ; echo ;   # Root Partition
         echo w;) | fdisk /dev/"$disk";  # Write the configuration to disk.
    fi
    
    echo p | fdisk /dev/"$disk";
}

# Format the Hard Disk
format_disk() {
    mkfs."$bootfs" /dev/"$disk""$partition"1;  	# Format the boot partition.

    if [ "$swap" = true ]
    then { 
        # Format the disk partitions with swap.
        mkswap /dev/"$disk""$partition"2           # Format the swap partition.
        swapon /dev/"$disk""$partition"2           # Enable the swap partition.
        mkfs."$rootfs" /dev/"$disk""$partition"3;  # Format the root partition.
    }
    else
        # Format the disk partitions without swap.
        mkfs."$rootfs" /dev/"$disk""$partition"2;  # Format the root partition.
    fi

    df -Th;
}

# Mount the Partitions
mount_partitions() {
    if [ "$swap" = true ]
    then { 
        # Mount the root partition with swap.
        mount /dev/"$disk""$partition"3 /mnt;   # Mount the root partition.
    }
    else
        # Mount the root partition without swap.
        mount /dev/"$disk""$partition"2 /mnt;   # Mount the root partition.
    fi

    mkdir /mnt/boot;                            # Create a boot directory to mount to.
    mount /dev/"$disk""$partition"1 /mnt/boot;  # Mount the boot partition.

    mount;
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
    
    head -n 5 /etc/pacman.d/mirrorlist;
}

# Configure the fstab File
configure_fstab() {
    genfstab -U -p /mnt >> /mnt/etc/fstab;

    cat /mnt/etc/fstab;
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

    if [ "$swap" = true ]
    then { 
        # Set the root partition with swap.
        echo 'options   root=/dev/'"$disk""$partition"'3 rw' >> /mnt/boot/loader/entries/arch.conf;
    }
    else
        # Set the root partition without swap.
        echo 'options   root=/dev/'"$disk""$partition"'2 rw' >> /mnt/boot/loader/entries/arch.conf;
    fi

    # Update the bootloader
    arch-chroot /mnt bootctl update;

    cat /mnt/boot/loader/loader.conf;
    cat /mnt/boot/loader/entries/arch.conf;
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
pacstrap /mnt ntp;
pacstrap /mnt vim;
pacstrap /mnt wget;
pacstrap /mnt polkit;                   # Allow users to issue power-related commands
pacstrap /mnt alsa-utils;               # Audio Management

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
