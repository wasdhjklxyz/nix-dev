add-module() {
  if [[ -z "$1" ]]; then
    echo "Usage: add-module <path/to/module.ko>"
    return 1
  fi

  local tmp_dir=$(mktemp -d)
  local modules_dir=$tmp_dir/lib/modules/$KERNEL_VERSION
  mkdir -p $modules_dir
  cp "$1" $modules_dir

  (cd $tmp_dir && find . | cpio -ov --format=newc) > $tmp_dir/module.cpio
  cat $INITRAMFS $tmp_dir/module.cpio > $INITRAMFS

  rm -rf $tmp_dir
}
