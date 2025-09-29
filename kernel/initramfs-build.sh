mkdir -p initramfs/bin
cp $BUSYBOX_BIN initramfs/bin
for cmd in $($BUSYBOX_BIN --list); do
  ln -sf busybox initramfs/bin/$cmd
done

cat > initramfs/init << 'EOF'
#!/bin/sh
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
exec /bin/sh
EOF
chmod +x initramfs/init

(cd initramfs && find . | cpio -ov --format=newc) > initramfs.cpio
