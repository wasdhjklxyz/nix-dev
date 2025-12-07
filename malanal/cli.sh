set -euo pipefail

SANDBOX_DIR="${MALANAL_SANDBOX_DIR:-$HOME/.cache/nix-malanal-dev/malanal-sandbox}"

cmd_convert() {
  [[ $# -eq 0 ]] && { echo "Usage: malanal convert <file.ova>"; exit 1; }
  [[ -f "$1" ]] || { echo "File not found: $1"; exit 1; }

  local ova_path="$(realpath "$1")"

  mkdir -p "$SANDBOX_DIR"
  cd "$SANDBOX_DIR"

  echo "Extracting..."
  tar xvf "$ova_path"

  shopt -s nullglob dotglob
  vmdk_files=(*.vmdk)
  shopt -u dotglob

  if [[ ${#vmdk_files[@]} -eq 0 ]]; then
    echo "Error: No VMDK files found in OVA"
    exit 1
  fi

  for vmdk in "${vmdk_files[@]}"; do
    base="${vmdk#.}"
    base="${base%.vmdk}"
    qcow2="${base}.qcow2"
    overlay="${base}-overlay.qcow2"
    echo "Converting $vmdk -> $qcow2"
    qemu-img convert -f vmdk -O qcow2 -p "$vmdk" "$qcow2"
    echo "Creating overlay $overlay"
    qemu-img create -f qcow2 -b "$qcow2" -F qcow2 "$overlay"
  done

  rm -f .*.ovf .*.mf .*.vmdk *.ovf *.mf
}

cmd_launch() {
  shopt -s nullglob
  overlays=("$SANDBOX_DIR"/*-overlay.qcow2)

  if [[ ${#overlays[@]} -eq 0 ]]; then
    echo "Error: no overlay found"
    exit 1
  fi

  overlay="${overlays[0]}"

  echo "Launching VM: $overlay"

  exec qemu-system-x86_64 \
    -m 8G \
    -smp 4 \
    -drive file="$overlay",if=ide,cache=unsafe \
    -net none \
    -vga std \
    -display sdl \
    -snapshot \
    -monitor stdio \
    -rtc base=localtime \
    -cpu qemu64 \
    -enable-kvm 2>/dev/null || \
  exec qemu-system-x86_64 \
    -name "Malware-Sandbox" \
    -m 8G \
    -smp 4 \
    -drive file="$overlay",if=ide,cache=unsafe \
    -net none \
    -vga std \
    -display sdl \
    -snapshot \
    -monitor stdio \
    -rtc base=localtime \
    -cpu qemu64
}

case "${1:-}" in
  convert) shift; cmd_convert "$@" ;;
  launch)  cmd_launch ;;
  *)
    cat << EOF
Usage: malanal <command>

Commands:
  convert <file.ova>  - Convert OVA to QEMU sandbox
  launch              - Launch sandboxed VM
EOF
    exit 1
    ;;
esac
