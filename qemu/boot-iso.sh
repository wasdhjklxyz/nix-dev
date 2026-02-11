#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-x86_64}"
ISO="${1:?Usage: $0 <iso-file> [disk-file]}"
DISK="${2:-./disk.qcow2}"

[[ -f "$ISO" ]] || { echo "ISO not found: $ISO" >&2; exit 1; }
[[ -f "$DISK" ]] || { qemu-img create -f qcow2 "$DISK" 20G; }

case "$ARCH" in
  x86_64)
    QEMU_CMD="qemu-system-x86_64"
    QEMU_OPTS=(-enable-kvm)
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
  -m 8G -smp 6 \
  "${QEMU_OPTS[@]}" \
  -boot d \
  -cdrom "$ISO" \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nic user,model=virtio-net-pci \
  -display gtk 2>/dev/null || \
$QEMU_CMD \
  -m 8G -smp 6 \
  "${QEMU_OPTS[@]/#-enable-kvm/}" \
  -boot d \
  -cdrom "$ISO" \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nic user,model=virtio-net-pci \
  -display gtk
