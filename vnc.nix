{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ tigervnc ];
  shellHook = ''
    NAME="vnc"
    ${builtins.readFile ./nix-develop-stack.sh}
    vncviewer --version 2>&1 | head -2
    vncviewer
  '';
}
