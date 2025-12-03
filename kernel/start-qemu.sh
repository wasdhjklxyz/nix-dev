start-qemu() {
  local role=${1:-client}
  local vm_ip mac_suffix ps1_color ps1_name tap_dev sock_path

  if ! grep -q CONFIG_9P_FS=y $KDIR/.config 2>/dev/null; then
    echo "Warning: Kernel may not have 9P support (CONFIG_9P_FS)" >&2
  fi

  case $role in
    client)
      vm_ip="192.0.2.2"
      mac_suffix="02"
      ps1_color="34" # blue
      ps1_name="client"
      tap_dev="tap_client"
      sock_path="/tmp/qemu-client.sock"
      ;;
    server)
      vm_ip="192.0.2.3"
      mac_suffix="03"
      ps1_color="32" # green
      ps1_name="server"
      tap_dev="tap_server"
      sock_path="/tmp/qemu-server.sock"
      ;;
    peer)
      vm_ip="192.0.2.4"
      mac_suffix="04"
      ps1_color="31" # red
      ps1_name="peer"
      tap_dev="tap_peer"
      sock_path="/tmp/qemu-peer.sock"
      ;;
    *)
      echo "Usage: $0 {client|server|peer}" >&2
      return 1
      ;;
  esac

  if ! ip link show $tap_dev &>/dev/null; then
    echo "Creating $tap_dev..."
    sudo ip tuntap add dev $tap_dev mode tap user $USER
    sudo ip link set $tap_dev up
  fi

  if ! ip link show br0 &>/dev/null; then
    echo "Creating bridge br0..."
    sudo ip link add br0 type bridge
    sudo ip link set br0 up
    sudo ip addr add 192.0.2.1/24 dev br0
  fi

  if ! bridge link show | grep -q $tap_dev; then
    sudo ip link set $tap_dev master br0
  fi

  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
    -nographic \
    -append "console=ttyS0 panic=1 role=$role vm_ip=$vm_ip ps1_color=$ps1_color ps1_name=$ps1_name $2" \
		-no-reboot \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
    -serial mon:stdio \
    -serial unix:$sock_path,server,nowait \
    -netdev tap,id=net0,ifname=$tap_dev,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:00:00:${mac_suffix} \
		-enable-kvm $3 $4 2>/dev/null || \
  qemu-system-x86_64 \
    -kernel $KDIR/arch/x86_64/boot/bzImage \
    -initrd $INITRAMFS \
		-nographic \
		-no-reboot \
    -append "console=ttyS0 panic=1 role=$role vm_ip=$vm_ip ps1_color=$ps1_color ps1_name=$ps1_name $2" \
    -serial mon:stdio \
    -serial unix:$sock_path,server,nowait \
    -virtfs local,path=$(pwd),mount_tag=hostshare,security_model=none \
    -netdev tap,id=net0,ifname=$tap_dev,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:00:00:${mac_suffix} $3 $4
}

qemu-tty() {
  local role=${1:-client}
  local sock="/tmp/qemu-${role}.sock"
  [[ ! -S "$sock" ]] && { echo "No QEMU socket at $sock" >&2; return 1; }
  socat unix-connect:"$sock" -,raw,echo=0
}

cleanup-qemu() {
  echo "Cleaning up QEMU network interfaces..."
  for tap in tap_client tap_server tap_peer; do
    if ip link show $tap &>/dev/null; then
      echo "Removing $tap from bridge..."
      sudo ip link set $tap nomaster 2>/dev/null || true
      sudo ip link set $tap down
      sudo ip link delete $tap
    fi
  done
  if ip link show br0 &>/dev/null; then
    echo "Removing bridge br0..."
    sudo ip link set br0 down
    sudo ip link delete br0
  fi
  echo "Removing sockets..."
  rm -f /tmp/qemu-client.sock \
        /tmp/qemu-server.sock \
        /tmp/qemu-peer.sock \
        /tmp/qemu-serial.sock
}

debug-qemu() {
  start-qemu $1 "nokaslr" "-s"
}

qemu-gdb() {
  gdb $VMLINUX \
    -ex "target remote :1234" \
    -ex "lx-symbols" \
    -ex "b start_kernel"
}
