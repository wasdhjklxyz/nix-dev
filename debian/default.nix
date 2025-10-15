{ pkgs, self, system }:
let
  name = ''\033[33mdebian\033[39m'';
  debian = pkgs.stdenv.mkDerivation {
    pname = "debian";
    version = "13.1.0";
    src = pkgs.fetchurl {
      url = "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.1.0-amd64-standard.iso";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    buildInputs = with pkgs; [];
    configurePhase = builtins.readFile ./configure.sh;
    buildPhase = builtins.readFile ./build.sh;
    installPhase = builtins.readFile ./install.sh;
  };
in {
  packages = { inherit debian; };
  devShell = pkgs.mkShell {
    buildInputs = with pkgs; [ debian ];
    shellHook = ''
      NAME="debian-vm"
      ${builtins.readFile ../nix-develop-stack.sh}
      ${builtins.readFile ./export.sh}
    '';
  };
}
