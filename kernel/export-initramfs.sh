export INITRAMFS="$CACHE_DIR/$(basename "$INITRAMFS_SRC")/initramfs.cpio"
if [[ ! -f "$INITRAMFS" ]]; then
  mkdir -p "$(dirname "$INITRAMFS")"
  cp "$INITRAMFS_SRC/initramfs.cpio" "$INITRAMFS"
  chmod +w "$INITRAMFS"
fi
