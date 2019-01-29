#!/bin/bash

# Setup a QEMU-KVM Host

# Configure the Bridge Network using iproute2
cp ./network/interfaces /etc/network/interfaces

cp ./systemd/network-bridge.service /etc/systemd/system/network-bridge.service
chmod 755 /etc/systemd/system/network-bridge.service

cp ./bin/setup_br0.sh /usr/local/sbin/setup_br0.sh
chmod 744 /usr/local/sbin/setup_br0.sh

systemctl enable network-bridge.service

# Install QEMU/KVM
apt -y install qemu-system-x86 qemu-utils

# Add the local user to the KVM group
usermod -a -G kvm $(awk -v uid=1000 -F":" '{ if($3==uid){print $1} }' /etc/passwd)

# Create the Images directory.
mkdir -p /var/lib/qemu-kvm/images
chown root:kvm /var/lib/qemu-kvm/
chown root:kvm /var/lib/qemu-kvm/images/
chmod 775 /var/lib/qemu-kvm/
chmod 775 /var/lib/qemu-kvm/images/

