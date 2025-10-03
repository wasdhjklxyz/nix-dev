{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ nodejs ];
  shellHook = ''
    NAME="cancer"
    ${builtins.readFile ./nix-develop-stack.sh}
    echo "npm version $(npm --version)"
  '';
}
