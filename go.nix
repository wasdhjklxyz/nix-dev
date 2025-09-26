{ pkgs }:
let
  name = ''\033[36mgo-dev\033[39m'';
in pkgs.mkShell {
  buildInputs = with pkgs; [ go gopls ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"
    go version
    gopls version
  '';
}
