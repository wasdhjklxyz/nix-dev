{ pkgs }:
let
  name = ''\033[31mcancer-dev\033[39m'';
in pkgs.mkShell {
  buildInputs = with pkgs; [ nodejs ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    echo "npm version $(npm --version)"
  '';
}
