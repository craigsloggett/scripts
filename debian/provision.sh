#!/bin/bash

# Setup the Debian Host: this script is to be run as root

# Install sudo for the first non-root user created.
apt install sudo
usermod -a -G sudo $(awk -v uid=1000 -F":" '{ if($3==uid){print $1} }' /etc/passwd)

# Setup Automatic Security Updates
apt install unattended-upgrades
# TODO: Replace in line sources for automatic upgrades in /etc/apt/apt.conf.d/50unattended-upgrades
unattended-upgrade -d

# Install nftables
apt install nftables
cp ./nftables/nftables.conf /etc/nftables.conf
systemctl enable nftables
systemctl start nftables

# Mount the Storage Volume
mkdir /srv/storage
# TODO: Append to /etc/fstab the UUID of the Storage Mount
