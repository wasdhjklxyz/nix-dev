{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ mosquitto mosquitto.dev ];
  shellHook = ''
    NAME="mosquitto"
    ${builtins.readFile ./nix-develop-stack.sh}
    mosquitto -h | head -1
  '';
}
