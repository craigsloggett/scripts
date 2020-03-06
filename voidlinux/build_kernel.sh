#!/bin/bash

BOOTDIR=/mnt/boot
TARGET=$BOOTDIR/EFI/boot
CMDLINE_DIR=$BOOTDIR/
EFISTUB=$BOOTDIR/linuxx64.efi.stub

for k in $BOOTDIR/vmlinuz*; do
	NAME=$(basename $k | sed 's/vmlinuz-//')
	INITRD="$BOOTDIR/initramfs-$NAME.img"
	CMDLINE="$CMDLINE_DIR/cmdline.txt"

    echo "root=/dev/nvme0n1p2 rw initrd=\\initramfs-$NAME.img" > "$CMDLINE"

	objcopy \
	    --add-section .osrel="$BOOTDIR/os-release" --change-section-vma .osrel=0x20000 \
	    --add-section .cmdline="$CMDLINE" --change-section-vma .cmdline=0x30000 \
	    --add-section .linux="$k" --change-section-vma .linux=0x40000 \
	    --add-section .initrd="$INITRDFILE" --change-section-vma .initrd=0x3000000 \
	    "$EFISTUB" "$TARGET/bootx64.efi"
done
