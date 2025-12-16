{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [
    qemu
    (writeScriptBin "qemu-boot-iso" "${builtins.readFile ./boot-iso.sh}")
    (writeScriptBin "qemu-netboot" "${builtins.readFile ./netboot.sh}")
  ];
  shellHook = ''
    NAME="qemu"
    ${builtins.readFile ../nix-develop-stack.sh}
    echo "[Versions]"
    echo "  $(qemu-system-x86_64 --version | head -1)"
    echo "[Scripts]"
    echo "  qemu-boot-iso: Start QEMU using provided ISO file"
    echo "  qemu-netboot: Start QEMU using provided netboot toplevel"
  '';
}
