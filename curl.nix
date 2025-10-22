{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ curl ];
  shellHook = ''
    NAME="curl"
    ${builtins.readFile ./nix-develop-stack.sh}
    curl --version | head -1
    curl-config --version
  '';
}
