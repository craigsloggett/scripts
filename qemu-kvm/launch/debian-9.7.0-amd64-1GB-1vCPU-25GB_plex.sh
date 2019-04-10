#!/bin/bash

# QEMU name and PID
OPTS="-name Plex Media Server"
OPTS="$OPTS -pidfile /tmp/debian-9.7.0-amd64-1GB-1vCPU-25GB_plex.pid"

# Processor
# -cpu kvm=off : This does not mean kvm virtualization is disabled, it merely hides the signature from the Guest OS
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp $(nproc)"
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
OPTS="$OPTS -drive file=/var/lib/qemu-kvm/images/debian-9.7.0-amd64-standard-25GB_plex.qcow2,media=disk,if=virtio"

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
