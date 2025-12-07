{ pkgs }:
let
  cli = pkgs.writeShellScriptBin "malanal" (builtins.readFile ./cli.sh);
in pkgs.mkShell {
  buildInputs = with pkgs; [ qemu_kvm qemu-utils wireshark ] ++ [ cli ];
  shellHook = ''
    NAME="malanal"
    ${builtins.readFile ../nix-develop-stack.sh}
    export MALANAL_SANDBOX_DIR="$HOME/.cache/nix-malanal-dev/malanal-sandbox"
    echo "[Versions]"
    echo "  $(qemu-kvm --version | head -1)"
    echo "  $(wireshark --version 2>/dev/null | head -1)"
    echo "[Exported]"
    echo "  MALANAL_SANDBOX_DIR=$MALANAL_SANDBOX_DIR"
    echo "[Commands]"
    echo "  malanal convert <file.ova>  - Convert OVA to QEMU sandbox"
    echo "  malanal launch              - Launch sandboxed VM"
  '';
}
