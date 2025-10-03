{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ sqlite ];
  shellHook = ''
    NAME="sqlite"
    ${builtins.readFile ./nix-develop-stack.sh}
    echo "sqlite version $(sqlite3 --version | awk '{print $1}')"
  '';
}
