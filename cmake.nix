{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ cmake ];
  shellHook = ''
    NAME="cmake"
    ${builtins.readFile ./nix-develop-stack.sh}
    cmake --version | head -1
  '';
}
