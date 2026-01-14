#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-x86_64}"
RESULT="${1:-./result}"
RESULT=$(readlink -f "$RESULT")
DISK="${2:-./disk.qcow2}"

case "$ARCH" in
  x86_64)
    KERNEL="$RESULT/bzImage"
    QEMU_CMD="qemu-system-x86_64"
    QEMU_OPTS=(-enable-kvm)
    CONSOLE="ttyS0"
    ;;
  aarch64)
    KERNEL="$RESULT/bzImage"
    QEMU_CMD="qemu-system-aarch64"
    QEMU_OPTS=(-M virt -cpu cortex-a72)
    CONSOLE="ttyAMA0"
    ;;
  *)
    echo "Unknown arch: $ARCH" >&2; exit 1
    ;;
esac

INITRD="$RESULT/initrd.gz"
INIT_PATH=$(grep -oP 'init=\K[^ ]+' "$RESULT/kexec-boot")

[[ -f "$KERNEL" ]] || { echo "Missing kernel: $KERNEL" >&2; exit 1; }
[[ -f "$INITRD" ]] || { echo "Missing initrd" >&2; exit 1; }
[[ -f "$DISK" ]] || { qemu-img create -f qcow2 "$DISK" 20G; }

$QEMU_CMD \
  -m 4G -smp 4 \
  "${QEMU_OPTS[@]}" \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "init=$INIT_PATH console=$CONSOLE loglevel=4" \
  -nic user,model=virtio-net-pci \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nographic 2>/dev/null || \
$QEMU_CMD \
  -m 4G -smp 4 \
  "${QEMU_OPTS[@]/#-enable-kvm/}" \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "init=$INIT_PATH console=$CONSOLE loglevel=4" \
  -nic user,model=virtio-net-pci \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -nographic
