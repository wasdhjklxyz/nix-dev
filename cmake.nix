{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ cmake pkg-config ];
  shellHook = ''
    NAME="cmake"
    ${builtins.readFile ./nix-develop-stack.sh}
    cmake --version | head -1
    echo "pkg-config version $(pkg-config --version)"
  '';
}
