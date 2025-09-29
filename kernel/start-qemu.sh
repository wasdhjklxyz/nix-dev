start-qemu() {
  qemu-system-x86_64 \
    -kernel $KERNEL_BUILD/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS_FINAL \
    -nographic \
    -append "console=ttyS0 panic=1" \
		-no-reboot \
		-enable-kvm 2>/dev/null || \
  qemu-system-x86_64 \
		-kernel $(BUILD_DIR)/bzImage \
		-initrd $(BUILD_DIR)/initramfs.cpio \
		-nographic \
		-no-reboot \
		-append "console=ttyS0 panic=1"
}
