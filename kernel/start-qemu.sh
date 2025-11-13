start-qemu() {
  if ! grep -q CONFIG_9P_FS=y $KDIR/.config 2>/dev/null; then
    echo "Warning: Kernel may not have 9P support (CONFIG_9P_FS)" >&2
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
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1" \
    -serial mon:stdio \
    -serial unix:/tmp/qemu-serial.sock,server,nowait \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none
}

qemu-tty() {
  local sock="/tmp/qemu-serial.sock"
  [[ ! -S "$sock" ]] && { echo "No QEMU socket at $sock" >&2; return 1; }
  socat unix-connect:"$sock" -,raw,echo=0
}
