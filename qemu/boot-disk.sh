#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-x86_64}"
GRAPHICS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --graphics) GRAPHICS=true; shift ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) DISK="$1"; shift ;;
  esac
done

DISK="${DISK:?Usage: $0 [--graphics] <disk.qcow2>}"
[[ -f "$DISK" ]] || { echo "Disk not found: $DISK" >&2; exit 1; }

case "$ARCH" in
  x86_64)
    QEMU_CMD="qemu-system-x86_64"
    QEMU_OPTS=(-enable-kvm)
    $GRAPHICS && QEMU_OPTS+=(-vga virtio -display gtk)
    ;;
  aarch64)
    QEMU_CMD="qemu-system-aarch64"
    QEMU_OPTS=(-M virt -cpu cortex-a72 -bios /usr/share/qemu/edk2-aarch64-code.fd)
    ;;
  *)
    echo "Unknown arch: $ARCH" >&2; exit 1
    ;;
esac

DISPLAY_OPTS=()
if $GRAPHICS; then
  DISPLAY_OPTS+=(-vga virtio -display gtk)
else
  DISPLAY_OPTS+=(-nographic)
fi

$QEMU_CMD \
  -m 4G \
  -smp 4 \
  -drive file="$DISK",if=none,id=disk0,format=qcow2 \
  -device ahci,id=ahci \
  -device ide-hd,drive=disk0,bus=ahci.0 \
  -nic user,model=virtio-net-pci \
  "${DISPLAY_OPTS[@]}" \
  "${QEMU_OPTS[@]}" 2>/dev/null || \
$QEMU_CMD \
  -m 4G \
  -smp 4 \
  -drive file="$DISK",if=none,id=disk0,format=qcow2 \
  -device ahci,id=ahci \
  -device ide-hd,drive=disk0,bus=ahci.0 \
  -nic user,model=virtio-net-pci \
  "${DISPLAY_OPTS[@]}" \
  "${QEMU_OPTS[@]/#-enable-kvm/}"
