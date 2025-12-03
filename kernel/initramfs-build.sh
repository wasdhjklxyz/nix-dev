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

for param in $(cat /proc/cmdline); do
  case $param in
    role=*) ROLE=${param#*=} ;;
    vm_ip=*) VM_IP=${param#*=} ;;
    ps1_color=*) PS1_COLOR=${param#*=} ;;
    ps1_name=*) PS1_NAME=${param#*=} ;;
  esac
done

if grep -q 9p /proc/filesystems 2>/dev/null; then
  mkdir -p /mnt/host
  mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/host
fi

ip link set lo up
ip addr add 127.0.0.1/8 dev lo

ip link set eth0 up
ip addr add ${VM_IP:-192.0.2.2}/24 dev eth0
ip route add default via 192.0.2.1

export PS1="\[\e[1;${PS1_COLOR:-39}m\][${PS1_NAME:-root}@${VM_IP:-192.0.2.2}:\w]\[\e[0m\] # "

setsid /bin/sh </dev/ttyS1 >/dev/ttyS1 2>&1 &
exec /bin/sh
EOF
chmod +x initramfs/init

(cd initramfs && find . | cpio -ov --format=newc) > initramfs.cpio
