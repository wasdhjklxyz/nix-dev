{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ aflplusplus ];
  shellHook = ''
    NAME="afl
    ${builtins.readFile ./nix-develop-stack.sh}
    afl-fuzz --version
  '';
}
