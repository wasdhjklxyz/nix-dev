{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ age ssh-to-age ];
  shellHook = ''
    NAME="age"
    ${builtins.readFile ./nix-develop-stack.sh}
    age --version
  '';
}
