{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ valgrind ];
  shellHook = ''
    NAME="valgrind"
    ${builtins.readFile ./nix-develop-stack.sh}
    valgrind --version
  '';
}
