PROJECT_HASH=$(echo -n "$PWD" | sha256sum | cut -c1-8)
export KDIR="${XDG_CACHE_HOME:-$HOME/.cache}/nix-kernel-dev/$PROJECT_HASH"

if [[ -d "$KDIR" ]]; then
  rm -rf "$KDIR"
fi
mkdir -p "$KDIR"

cp -r "$LINUX_SRC" "$KDIR"
chmod -R +w "$KDIR"
find "$KERNEL_SRC/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
find "$KERNEL_SRC/tools" -type f -exec chmod +x {} \; 2>/dev/null || true
