{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ sops ];
  shellHook = ''
    NAME="sops"
    ${builtins.readFile ./nix-develop-stack.sh}
    sops --version | head -1
  '';
}
