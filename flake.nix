{
  description = "Collection of development shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          linux = pkgs.stdenv.mkDerivation {
            pname = "linux";
            version = "6.12.49";
            src = pkgs.fetchurl {
              url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.49.tar.xz";
              hash = "sha256-I0Yh4UbazOIkEElVXVUOT3pr3mfM1+8jLUesgUVCVSY=";
            };
            buildInputs = with pkgs; [
              flex
              bison
              bash  # Needed by patchShebangs
              bc
              elfutils
            ];
            postPatch = ''
              patchShebangs scripts/config
            '';
            configurePhase = builtins.readFile ./scripts/linux-configure.sh;
            buildPhase = builtins.readFile ./scripts/linux-build.sh;
          };
        });

      devShells = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          go = import ./go.nix { inherit pkgs; };
          cancer = import ./cancer.nix { inherit pkgs; };
          kernel = import ./kernel {
            inherit pkgs;
            inherit self system;
          };
        });
    };
}
