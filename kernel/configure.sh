make allnoconfig
./scripts/config --file .config \
  --enable CONFIG_64BIT \
  --enable CONFIG_INITRAMFS_SOURCE \
  --enable CONFIG_BLK_DEV_INITRD \
  --enable CONFIG_PRINTK \
  --enable CONFIG_BINFMT_ELF \
  --enable CONFIG_BINFMT_SCRIPT \
  --enable CONFIG_DEVTMPFS \
  --enable CONFIG_DEVTMPFS_MOUNT \
  --enable CONFIG_TTY \
  --enable CONFIG_SERIAL_8250 \
  --enable CONFIG_SERIAL_8250_CONSOLE \
  --enable CONFIG_PROC_FS \
  --enable CONFIG_SYS \
  --enable CONFIG_MODULES \
  --enable CONFIG_MODULE_UNLOAD \
  --enable CONFIG_NET
make olddefconfig
