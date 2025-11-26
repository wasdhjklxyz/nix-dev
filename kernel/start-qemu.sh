start-qemu() {
  if ! grep -q CONFIG_9P_FS=y $KDIR/.config 2>/dev/null; then
    echo "Warning: Kernel may not have 9P support (CONFIG_9P_FS)" >&2
  fi
  if ! ip link show tap0 &>/dev/null; then
    echo "Creating tap0..."
    sudo ip tuntap add dev tap0 mode tap user $USER
    sudo ip link set tap0 up
    sudo ip addr add 10.0.3.1/24 dev tap0
  fi
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
    -nographic \
    -append "console=ttyS0 panic=1" \
		-no-reboot \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
    -serial mon:stdio \
    -serial unix:/tmp/qemu-serial.sock,server,nowait \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0 \
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1" \
    -serial mon:stdio \
    -serial unix:/tmp/qemu-serial.sock,server,nowait \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0
}

qemu-tty() {
  local sock="/tmp/qemu-serial.sock"
  [[ ! -S "$sock" ]] && { echo "No QEMU socket at $sock" >&2; return 1; }
  socat unix-connect:"$sock" -,raw,echo=0
}
