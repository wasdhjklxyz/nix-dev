#!/usr/bin/env bash
set -euo pipefail

ISO="${1:?Usage $0 <iso-file>}"
[[ -f "$ISO" ]] || { echo "ISO not found: $ISO" >&2; exit 1; }

qemu-system-x86_64 \
  -m 4G \
  -smp 4 \
  -boot d \
  -cdrom "$ISO" \
  -nic user,model=virtio-net-pci \
  -display gtk \
  -vga virtio \
  -enable-kvm 2>/dev/null || \
qemu-system-x86_64 \
  -m 4G \
  -smp 4 \
  -boot d \
  -cdrom "$ISO" \
  -nic user,model=virtio-net-pci \
  -display gtk \
  -vga virtio
