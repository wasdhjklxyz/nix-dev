{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ go gopls delve ];
  shellHook = ''
    NAME="go"
    ${builtins.readFile ./nix-develop-stack.sh}
    go version
    gopls version
    dlv version
  '';
}
