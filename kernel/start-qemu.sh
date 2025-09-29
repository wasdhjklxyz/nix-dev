start-qemu() {
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
    -nographic \
    -append "console=ttyS0 panic=1" \
		-no-reboot \
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1"
}
