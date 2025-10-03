{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ go gopls goose ];
  shellHook = ''
    NAME="go"
    ${builtins.readFile ./nix-develop-stack.sh}
    go version
    gopls version
    goose --version
  '';
}
