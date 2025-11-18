{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [
    qemu
    (writeScriptBin "qemu-boot-iso" "${builtins.readFile ./boot-iso.sh}")
  ];
  shellHook = ''
    NAME="qemu"
    ${builtins.readFile ../nix-develop-stack.sh}
    qemu-system-x86_64 --version | head -1
  '';
}
