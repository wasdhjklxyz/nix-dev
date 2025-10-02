{ pkgs }:
let
  name = ''\033[34msqlite-dev\033[39m'';
in pkgs.mkShell {
  buildInputs = with pkgs; [ sqlite ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"
    echo "sqlite version $(sqlite3 --version | awk '{print $1}')"
  '';
}
