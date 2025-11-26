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
  mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/host
fi

ip link set lo up
ip addr add 127.0.0.1/8 dev lo

ip link set eth0 up
ip addr add 10.0.3.2/24 dev eth0
ip route add default via 10.0.3.1

setsid /bin/sh </dev/ttyS1 >/dev/ttyS1 2>&1 &
exec /bin/sh
EOF
chmod +x initramfs/init

(cd initramfs && find . | cpio -ov --format=newc) > initramfs.cpio
