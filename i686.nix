{ nixpkgs }:
let
  i686pkgs = nixpkgs.legacyPackages."i686-linux";
in i686pkgs.mkShell {
  buildInputs = with i686pkgs; [
    gcc
    glibc
    gdb
  ];
  shellHook = ''
    NAME="i686"
    ${builtins.readFile ./nix-develop-stack.sh}
  '';
}
