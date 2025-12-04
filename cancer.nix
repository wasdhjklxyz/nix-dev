{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ nodejs yarn ];
  shellHook = ''
    NAME="cancer"
    ${builtins.readFile ./nix-develop-stack.sh}
    echo "npm version $(npm --version)"
    echo "yarn version $(yarn --version)"
  '';
}
