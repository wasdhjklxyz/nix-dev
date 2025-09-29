INITRAMFS_DIR="$CACHE_DIR/$(basename "$INITRAMFS_SRC")"
INITRAMFS_BAK="$INITRAMFS_DIR/initramfs.cpio.bak"
export INITRAMFS="$INITRAMFS_DIR/initramfs.cpio"

if [[ -d "$INITRAMFS_DIR" ]]; then
  rm -rf "$INITRAMFS_DIR"
fi

mkdir -p "$INITRAMFS_DIR"
cp "$INITRAMFS_SRC/initramfs.cpio" "$INITRAMFS_BAK"
cp "$INITRAMFS_SRC/initramfs.cpio" "$INITRAMFS"
chmod +w "$INITRAMFS"
