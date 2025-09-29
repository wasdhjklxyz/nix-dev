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
    -fsdev local,id=host0,path=$(pwd),security_model=none \
    -device virtio-9p,fsdev=host0,mount_tag=hostshare \
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1" \
    -fsdev local,id=host0,path=$(pwd),security_model=none \
    -device virtio-9p,fsdev=host0,mount_tag=hostshare
}
