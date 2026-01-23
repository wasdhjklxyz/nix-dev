#!/usr/bin/env bash

set -euo pipefail

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
