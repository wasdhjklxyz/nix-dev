{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ nasm ];
  shellHook = ''
    NAME="nasm"
    ${builtins.readFile ./nix-develop-stack.sh}
    nasm --version
  '';
}
