{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ python314 uv basedpyright ruff ];
  shellHook = ''
    NAME="python"
    ${builtins.readFile ./nix-develop-stack.sh}
    export UV_PROJECT_ENVIRONMENT=".venv"
    python --version
    uv --version
    basedpyright --version
    ruff --version
  '';
}
