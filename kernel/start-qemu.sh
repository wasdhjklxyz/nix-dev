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
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1" \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none
}
