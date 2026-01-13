#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-x86_64}"
ISO="${1:?Usage: $0 <iso-file>}"
[[ -f "$ISO" ]] || { echo "ISO not found: $ISO" >&2; exit 1; }

case "$ARCH" in
  x86_64)
    QEMU_CMD="qemu-system-x86_64"
    QEMU_OPTS=(-enable-kvm -vga virtio)
    ;;
  aarch64)
    QEMU_CMD="qemu-system-aarch64"
    QEMU_OPTS=(-M virt -cpu cortex-a72 -bios /usr/share/qemu/edk2-aarch64-code.fd)
    ;;
  *)
    echo "Unknown arch: $ARCH" >&2; exit 1
    ;;
esac

$QEMU_CMD \
  -m 4G \
  -smp 4 \
  -boot d \
  -cdrom "$ISO" \
  -nic user,model=virtio-net-pci \
  -display gtk \
  "${QEMU_OPTS[@]}" 2>/dev/null || \
$QEMU_CMD \
  -m 4G \
  -smp 4 \
  -boot d \
  -cdrom "$ISO" \
  -nic user,model=virtio-net-pci \
  -display gtk \
  "${QEMU_OPTS[@]/#-enable-kvm/}"
