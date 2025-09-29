CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nix-kernel-dev"
export KDIR="$CACHE_DIR/$(basename "$LINUX_SRC")"

if [[ ! -d "$KDIR" ]]; then
  mkdir -p "$KDIR"
  cp -r "$LINUX_SRC" "$CACHE_DIR"
  chmod -R +w "$KDIR"
  find "$KDIR/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
  find "$KDIR/tools" -type f -exec chmod +x {} \; 2>/dev/null || true
fi
