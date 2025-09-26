{ pkgs }:
let
  name = ''\033[33mkernel-dev\033[39m'';
  kernelVersion = "6.12.49";
  setupKernel = pkgs.writeShellScriptBin "setup-kernel" ''
    export PATH=${pkgs.lib.makeBinPath [
      pkgs.wget
    ]}:$PATH
    KERNEL_VERSION=${kernelVersion}
    ${builtins.readFile ./setup-kernel.sh}
  '';
in pkgs.mkShell {
  buildInputs = with pkgs; [
    setupKernel
  ];
  shellHook = ''
    if [[ -n "$NIX_DEVELOP_STACK" ]]; then
      export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
    else
      export NIX_DEVELOP_STACK="${name}"
    fi
    export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"
  '';
}
