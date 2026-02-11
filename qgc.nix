{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ qgroundcontrol ];
  shellHook = ''
    NAME="qgroundcontrol"
    ${builtins.readFile ./nix-develop-stack.sh}
    alias qgroundcontrol="QGroundControl"
  '';
}
