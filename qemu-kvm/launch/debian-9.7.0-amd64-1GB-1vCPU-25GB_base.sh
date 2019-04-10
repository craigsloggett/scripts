#!/bin/bash

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
OPTS="$OPTS -device virtio-net,netdev=network0 -netdev user,id=network0,net=10.0.1.0/24,dhcpstart=10.0.1.10"
OPTS="$OPTS -device virtio-net,netdev=network1 -netdev tap,id=network1,ifname=tap0,script=no,downscript=no"

# Disable display
#OPTS="$OPTS -vga none"
#OPTS="$OPTS -serial null"
#OPTS="$OPTS -parallel null"
#OPTS="$OPTS -monitor none"
#OPTS="$OPTS -display none"
OPTS="$OPTS -vnc :0"
#OPTS="$OPTS -nographic"

# Daemonize
OPTS="$OPTS -daemonize"

qemu-system-x86_64 $OPTS
