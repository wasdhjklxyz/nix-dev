{ pkgs }:
let
  toolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
    ];
  };
in
pkgs.mkShell {
  packages = [
    toolchain
    pkgs.pkg-config
  ];
  shellHook = ''
    NAME="rust"
    ${builtins.readFile ./nix-develop-stack.sh}
    rustc --version
    cargo --version
  '';
}
