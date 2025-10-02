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
    go version
    gopls version
  '';
}
