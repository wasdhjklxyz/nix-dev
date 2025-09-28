{ pkgs, self, system }:
let
  name = ''\033[33mkernel-dev\033[39m'';
  linux = self.packages.${system}.linux;
in pkgs.mkShell {
  buildInputs = with pkgs; [ linux ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"

    export KERNEL_SRC=${linux}/src
    export KERNEL_BUILD=${linux}/build
  '';
}
