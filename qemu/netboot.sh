#!/usr/bin/env bash
set -euo pipefail

RESULT="${1:-./result}"
RESULT=$(readlink -f "$RESULT")
DISK="${2:-./disk.qcow2}"

KERNEL="$RESULT/bzImage"
INITRD="$RESULT/initrd.gz"
INIT_PATH=$(grep -oP 'init=\K[^ ]+' "$RESULT/kexec-boot")

[[ -f "$KERNEL" ]] || { echo "Missing kernel" >&2; exit 1; }
[[ -f "$INITRD" ]] || { echo "Missing initrd" >&2; exit 1; }
[[ -f "$DISK" ]] || { qemu-img create -f qcow2 "$DISK" 20G; }

qemu-system-x86_64 \
  -m 4G -smp 4 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "init=$INIT_PATH console=ttyS0 loglevel=4" \
  -nic user,model=virtio-net-pci \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nographic \
  -enable-kvm 2>/dev/null || \
qemu-system-x86_64 \
  -m 4G -smp 4 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "init=$INIT_PATH console=ttyS0 loglevel=4" \
  -nic user,model=virtio-net-pci \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nographic
