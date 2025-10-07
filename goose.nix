{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ goose ];
  shellHook = ''
    NAME="goose"
    ${builtins.readFile ./nix-develop-stack.sh}
    goose --version
  '';
}
