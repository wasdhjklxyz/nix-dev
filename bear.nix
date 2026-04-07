{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ bear ];
  shellHook = ''
    NAME="bear"
    ${builtins.readFile ./nix-develop-stack.sh}
    bear --version
  '';
}
