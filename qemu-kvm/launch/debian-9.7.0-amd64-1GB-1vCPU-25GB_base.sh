#!/bin/bash

# Generate a MAC address for the network interface based on the hostname of the machine.
HOSTNAME='DebianBox'; 
MAC=$(echo ${HOSTNAME} | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/');

# QEMU name and PID
OPTS="-name Debian_Stretch_9.7.0_base"
OPTS="$OPTS -pidfile /tmp/debian-9.7.0-amd64_base.pid"

# Processor
# -cpu kvm=off : This does not mean kvm virtualization is disabled, it merely hides the signature from the Guest OS
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 1"
OPTS="$OPTS -enable-kvm"

# Machine
# -machine type=q35 is an Intel Chipset that was developed later than 1997
OPTS="$OPTS -machine type=q35,accel=kvm"

# Memory
OPTS="$OPTS -m 1G"

# Hardware clock
OPTS="$OPTS -rtc clock=host,base=utc"

# Keyboard layout
OPTS="$OPTS -k en-us"

# Boot priority
#  c = first virtual hard drive
#  d = first virtual CD-ROM drive
OPTS="$OPTS -boot order=c"
#OPTS="$OPTS -boot order=d"

# System drive
OPTS="$OPTS -drive file=/var/lib/qemu-kvm/images/debian-9.7.0-amd64-25GB_base.img,format=raw,media=disk,if=virtio"

# OS installer
OPTS="$OPTS -drive file=/var/lib/qemu-kvm/iso/Debian/debian-9.7.0-amd64-netinst.iso,index=1,media=cdrom"

# QEMU accepts various commands and queries from the user on the monitor
# interface. Connect the monitor with the qemu process's standard input and
# output.
OPTS="$OPTS -monitor telnet:localhost:5555,server,nowait"

# Network
OPTS="$OPTS -netdev user,id=network0,ipv6=off -device virtio-net,netdev=network0"
OPTS="$OPTS -netdev tap,id=network1,ifname=tap0,script=no,downscript=no -device virtio-net,netdev=network1,mac=${MAC}"

# Enable VNC Display
OPTS="$OPTS -vnc :0"

# Daemonize
OPTS="$OPTS -daemonize"

qemu-system-x86_64 $OPTS
