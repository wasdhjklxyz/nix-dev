{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ pixiecore ];
  shellHook = ''
    NAME="pixiecore"
    ${builtins.readFile ./nix-develop-stack.sh}
    pixiecore
  '';
}
