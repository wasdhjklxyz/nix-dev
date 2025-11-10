{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [ python314 uv ];
  shellHook = ''
    NAME="python"
    ${builtins.readFile ./nix-develop-stack.sh}
    export UV_PROJECT_ENVIRONMENT=".venv"
    python --version
    uv --version
  '';
}
