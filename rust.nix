{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ cargo rustc rust-analyzer ];
  shellHook = ''
    NAME="rust"
    ${builtins.readFile ./nix-develop-stack.sh}
  '';
}
