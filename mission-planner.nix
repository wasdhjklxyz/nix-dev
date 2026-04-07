{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ mission-planner ];
  shellHook = ''
    NAME="mission-planner"
    ${builtins.readFile ./nix-develop-stack.sh}
  '';
}
