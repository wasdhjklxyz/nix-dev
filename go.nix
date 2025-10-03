{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ go gopls ];
  shellHook = ''
    NAME="go"
    ${builtins.readFile ./nix-develop-stack.sh}
    go version
    gopls version
  '';
}
