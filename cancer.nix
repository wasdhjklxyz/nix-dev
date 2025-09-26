{ pkgs }:
let
  name = ''\033[36mcancer-dev\033[39m'';
in pkgs.mkShell {
  buildInputs = with pkgs; [ nodejs ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"
    echo "npm version $(npm --version)"
  '';
}
