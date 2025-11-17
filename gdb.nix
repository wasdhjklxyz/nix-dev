{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ gdb ];
  shellHook = ''
    NAME="gdb"
    ${builtins.readFile ./nix-develop-stack.sh}
    gdb --version
  '';
}
