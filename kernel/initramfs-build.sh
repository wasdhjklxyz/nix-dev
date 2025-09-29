mkdir -p initramfs/{bin,proc,sys,dev,mnt,root}
cp $BUSYBOX_BIN initramfs/bin
for cmd in $($BUSYBOX_BIN --list); do
  ln -sf busybox initramfs/bin/$cmd
done

cat > initramfs/init << 'EOF'
#!/bin/sh

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

if grep -q 9p /proc/filesystems 2>/dev/null; then
  mkdir -p /mnt/host
  mount -t 9p -o trans=virtio hostshare /mnt/host 2>/dev/null && \
    echo "Host directory mounted at /mnt/host"
fi

exec /bin/sh
EOF
chmod +x initramfs/init

(cd initramfs && find . | cpio -ov --format=newc) > initramfs.cpio
