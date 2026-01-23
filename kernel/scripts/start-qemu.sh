#!/usr/bin/env bash

set -euo pipefail

ROLE=${1:-client}

if ! grep -q CONFIG_9P_FS=y $KDIR/.config 2>/dev/null; then
  echo "Warning: Kernel may not have 9P support (CONFIG_9P_FS)" >&2
fi

case $ROLE in
  client)
    VM_IP="192.0.2.2"
    MAC_SUFFIX="02"
    PS1_COLOR="34" # blue
    PS1_NAME="client"
    TAP_DEV="tap_client"
    SOCK_PATH="/tmp/qemu-client.sock"
    ;;
  peer)
    VM_IP="203.0.113.2"
    MAC_SUFFIX="13"
    PS1_COLOR="31" # red
    PS1_NAME="peer"
    TAP_DEV="tap_peer"
    SOCK_PATH="/tmp/qemu-peer.sock"
    ;;
  *)
    echo "Usage: $0 {client|server|peer}" >&2
    return 1
    ;;
esac

if ! ip link show $TAP_DEV &>/dev/null; then
  echo "Creating $TAP_DEV..."
  sudo ip tuntap add dev $TAP_DEV mode tap user $USER
  sudo ip link set $TAP_DEV up
fi

if ! ip link show br0 &>/dev/null; then
  echo "Creating bridge br0..."
  sudo ip link add br0 type bridge
  sudo ip link set br0 up
  sudo ip addr add 192.0.2.1/24 dev br0
  sudo ip addr add 203.0.113.1/24 dev br0
fi

if ! bridge link show | grep -q $TAP_DEV; then
  sudo ip link set $TAP_DEV master br0
fi

qemu-system-x86_64 \
  -kernel $KDIR/arch/x86_64/boot/bzImage \
  -initrd $INITRAMFS \
  -nographic \
  -append "console=ttyS0 panic=1 role=$ROLE vm_ip=$VM_IP ps1_color=$PS1_COLOR ps1_name=$PS1_NAME $2" \
  -no-reboot \
  -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
  -serial mon:stdio \
  -serial unix:$SOCK_PATH,server,nowait \
  -netdev tap,id=net0,ifname=$TAP_DEV,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:00:00:${MAC_SUFFIX} \
  -enable-kvm $3 $4 2>/dev/null || \
qemu-system-x86_64 \
  -kernel $KDIR/arch/x86_64/boot/bzImage \
  -initrd $INITRAMFS \
  -nographic \
  -no-reboot \
  -append "console=ttyS0 panic=1 role=$ROLE vm_ip=$VM_IP ps1_color=$PS1_COLOR ps1_name=$PS1_NAME $2" \
  -serial mon:stdio \
  -serial unix:$SOCK_PATH,server,nowait \
  -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
  -netdev tap,id=net0,ifname=$TAP_DEV,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:00:00:${MAC_SUFFIX} $3 $4
