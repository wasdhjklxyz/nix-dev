{ pkgs }: pkgs.mkShell {
  packages = with pkgs; [ luajit lua-language-server stylua ];
  shellHook = ''
    NAME="lua"
    ${builtins.readFile ./nix-develop-stack.sh}
    lua -v
    echo "lua-language-server $(lua-language-server --version)"
    stylua --version
  '';
}
