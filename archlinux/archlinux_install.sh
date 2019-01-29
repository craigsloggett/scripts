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

# Options (Comment out options to set to false)
virtualbox=false;    # Setup the VirtualBox Guest Additions
swap=false;          # Setup a Swap partition
debug=false;         # Require user input to proceed

# Hardware
#disk='sda';         # VirtualBox Hard Disk
disk='nvme0n1';     # Dell XPS Hard Disk
#partition='';       # VirtualBox partition prefix
partition='p';      # Dell XPS partition prefix
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

# Partition the Hard Disk
partition_disk() {

    echo ' Partitioning '"$disk"'...'

    (echo g; echo n; echo 1; echo ; echo +"$bootsize"; # Boot Partition
     echo t; echo 1;                                   # Change the Boot Partition to EFI Type
     echo w;) | fdisk /dev/"$disk";                    # Write the Configuration to Disk

    if [ "$swap" = true ]
    then { 
        # Create partitions with Swap
        (echo n; echo 2; echo ; echo +"$swapsize"; # Swap Partition
         echo n; echo 3; echo ; echo ;             # Root Partition
         echo t; echo 2; echo 19;                  # Change the Swap Partition to Linux Swap Type
         echo w;) | fdisk /dev/"$disk";            # Write the Configuration to Disk
    }
    else
        # Create Partitions without Swap
        (echo n; echo 2; echo ; echo ;  # Root Partition
         echo w;) | fdisk /dev/"$disk"; # Write the Configuration to Disk
    fi
    
    if [ "$debug" = true ]
    then { 
        echo p | fdisk /dev/"$disk";
        echo "\nCompleted Disk Partition, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Disk Partition.";
    fi
}

# Format the Hard Disk
format_disk() {
    echo ' Formatting '"$disk"'...'

    mkfs."$bootfs" /dev/"$disk""$partition"1;  	# Format Boot Partition

    if [ "$swap" = true ]
    then { 
        # Format the Partitions with Swap
        mkswap /dev/"$disk""$partition"2           # Create the Swap Partition
        swapon /dev/"$disk""$partition"2           # Enable the Device for Paging
        mkfs."$rootfs" /dev/"$disk""$partition"3;  # Format Root Partition
    }
    else
        # Format the Partitions without Swap
        mkfs."$rootfs" /dev/"$disk""$partition"2;  # Format Root Partition
    fi

    if [ "$debug" = true ]
    then { 
        df -Th;
        echo "\nCompleted Formatting the Partitions, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Formatting the Partitions.";
    fi
}

# Mount the Partitions
mount_partitions() {
    echo ' Mounting '"$disk"'...'
    
    if [ "$swap" = true ]
    then { 
        # Mount the Root Partition (3)
        mount /dev/"$disk""$partition"3 /mnt;   # Mount the Root Partition
    }
    else
        # Mount the Root Partition (2)
        mount /dev/"$disk""$partition"2 /mnt;   # Mount the Root Partition
    fi

    mkdir /mnt/boot;                            # Make  the Boot Directory
    mount /dev/"$disk""$partition"1 /mnt/boot;  # Mount the Boot Partition

    if [ "$debug" = true ]
    then { 
        mount;
        echo "\nCompleted Mounting the Partitions, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Mounting the Partitions.";
    fi
}

# Sort the Mirror List by Location and Availability (Putting the Closest at the Top)
sort_mirror_list() {
    url="https://www.archlinux.org/mirrorlist/?country=$country&protocol=https&ip_version=4&use_mirror_status=on"
    tmpfile=$(mktemp --suffix=-mirrorlist)

    # Get latest mirror list and save to tmpfile
    echo " Downloading the latest mirrorlist..."
    wget -qO- "$url" | sed 's/^#Server/Server/g' > "$tmpfile"

    # Backup and replace current mirrorlist file (if new file is non-zero)
    if [ -s "$tmpfile" ]
    then { 
        echo " Backing up the original mirrorlist..."
        mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; 
    } && { 
        echo " Rotating the new list into place..."
        mv -i "$tmpfile" /etc/pacman.d/mirrorlist; 
    }
    else
        echo " Unable to update, could not download list."
    fi

    # allow global read access (required for non-root yaourt execution)
    chmod +r /etc/pacman.d/mirrorlist

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted sorting the Mirror List. The sorted list can be found in /etc/pacman.d/mirrorlist, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted sorting the Mirror List. The sorted list can be found in /etc/pacman.d/mirrorlist";
    fi
}

# Configure the fstab File
configure_fstab() {
    echo ' Generating fstab...';
    genfstab -U -p /mnt >> /mnt/etc/fstab;

    if [ "$debug" = true ]
    then { 
        cat /mnt/etc/fstab;
        echo "\nfstab has been generated, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nfstab has been generated.";
    fi
}

# Configure the System Locale
configure_locale() {
    echo ' Setting up Locale...';
    touch locale.conf_new
    echo 'LANG='"$locale" > locale.conf_new;
    export LANG="$locale";
    cp locale.conf_new /mnt/etc/locale.conf
    rm locale.conf_new
    # Create a backup of the current locale.gen file
    cp /mnt/etc/locale.gen /mnt/etc/locale.gen_bak;
    # Remove the leading # to uncomment the desired locale
    sed 's/#'"$locale"'/'"$locale"'/g' /mnt/etc/locale.gen_bak > /mnt/etc/locale.gen;
    rm /mnt/etc/locale.gen_bak;
    # Generate the locale
    arch-chroot /mnt locale-gen;
    arch-chroot /mnt locale -a;

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted Locale Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Locale Configuration.";
    fi
}

# Configure the Hostname
configure_hostname() {
    echo ' Configuring the Hostname...';
    echo "$hostname" > /mnt/etc/hostname;

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted Hostname Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Hostname Configuration.";
    fi
}

# Configure the Network
configure_network() {
    echo ' Configuring the Network...';
    arch-chroot /mnt systemctl enable dhcpcd.service;

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted Network Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Network Configuration.";
    fi
}

# Configure the Non-Root User
configure_user() {
    echo ' Setting up non-root user: '"$username"'...';
    arch-chroot /mnt useradd -m -g users -G wheel,video -s /bin/bash $username;
    (echo "$password"; echo "$password";) | arch-chroot /mnt passwd $username;

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted User Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted User Configuration.";
    fi
}

# Configure the Bootloader
configure_bootloader() {
    echo ' Setting up Bootloader...';
    # Using systemd and bootctl
    arch-chroot /mnt bootctl --path=/boot install;
    # Configure bootctl                                                                                    
    mkdir -p /mnt/boot/loader;
    mkdir -p /mnt/boot/loader/entries;
    cp -v /mnt/usr/share/systemd/bootctl/loader.conf /mnt/boot/loader/loader.conf;
    echo 'timeout 4' >> /mnt/boot/loader/loader.conf;
    echo 'editor  0' >> /mnt/boot/loader/loader.conf;
    echo 'title     Arch Linux' > /mnt/boot/loader/entries/arch.conf;
    echo 'linux     /vmlinuz-linux' >> /mnt/boot/loader/entries/arch.conf;
    # Setup intel microcode updates?
    if [ "$virtualbox" = true ]
    then { 
        : # No Need to Setup Intel Microcode Updates
    }
    else
        # Setup Intel Microcode Updates
        echo 'initrd    /intel-ucode.img' >> /mnt/boot/loader/entries/arch.conf;
    fi
    echo 'initrd    /initramfs-linux.img' >> /mnt/boot/loader/entries/arch.conf;
    if [ "$swap" = true ]
    then { 
        # Set the Root partition with Swap
        echo 'options   root=/dev/'"$disk""$partition"'3 rw' >> /mnt/boot/loader/entries/arch.conf;
    }
    else
        # Set the Root partition without Swap
        echo 'options   root=/dev/'"$disk""$partition"'2 rw' >> /mnt/boot/loader/entries/arch.conf;
    fi
    
    if [ "$debug" = true ]
    then { 
        cat /mnt/boot/loader/loader.conf;
        cat /mnt/boot/loader/entries/arch.conf;
        echo "\nCompleted Bootloader Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Bootloader Configuration.";
    fi
    # Update the bootloader
    arch-chroot /mnt bootctl update;
}

# Set the Root Password
set_root_password() {
    echo ' Setting the Root Password to Default ('"$password"')';
    (echo "$password"; echo "$password";) | arch-chroot /mnt passwd;

    if [ "$debug" = true ]
    then { 
        echo "\nCompleted Root Password Configuration, press any key to proceed...";
        read -n 1;
    }
    else
        echo "\nCompleted Root Password Configuration.";
    fi
}

# Disk Setup
partition_disk     # Partition the Hard Disk
format_disk        # Format the Hard Disk
mount_partitions   # Mount the Partitions

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

# Configure the System
configure_fstab         # Configure the fstab File
configure_locale        # Configure the system locale
configure_hostname      # Configure the Hostname
configure_network       # Configure the Network
configure_user          # Configure the Non-root User
configure_bootloader    # Configure the EFI Bootloader

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

echo 'Installation Completed. Please Restart the Machine.';
