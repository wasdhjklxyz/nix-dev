add-module() {
  if [[ -z "$1" ]]; then
    echo "Usage: add-module <path/to/module.ko>"
    return 1
  fi

  local tmp_dir=$(mktemp -d)
  local modname=$(basename "$1")

  mkdir -p "$tmp_dir"
  (cd "$tmp_dir" && cat "$INITRAMFS" | cpio -idm --quiet)

  install -D -m 0644 "$1" "$tmp_dir/lib/modules/$KERNEL_VERSION/extra/$modname"

  depmod -a -b "$tmp_dir" "$KERNEL_VERSION"

  (cd "$tmp_dir" && find . | cpio -ov --format=newc) > "${INITRAMFS}.new"
  mv "${INITRAMFS}.new" "$INITRAMFS"

  rm -rf "$tmp_dir"
}

reset-modules() {
  cp "$INITRAMFS.bak" "$INITRAMFS"
  chmod +w "$INITRAMFS"
}
