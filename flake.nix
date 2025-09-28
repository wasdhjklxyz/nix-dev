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
          kernelStuff = import ./kernel { inherit pkgs self system; };
        in {
          linux = pkgs.stdenv.mkDerivation {
            pname = "linux";
            version = "6.12.49";
            src = pkgs.fetchurl {
              url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.49.tar.xz";
              hash = "sha256-I0Yh4UbazOIkEElVXVUOT3pr3mfM1+8jLUesgUVCVSY=";
            };
          };
        });

      devShells = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          kernelStuff = import ./kernel { inherit pkgs self system; };
        in {
          go = import ./go.nix { inherit pkgs; };
          cancer = import ./cancer.nix { inherit pkgs; };
          kernel = kernelStuff.devShell;
          sqlite = import ./sqlite.nix { inherit pkgs; };
          cmake = import ./cmake.nix { inherit pkgs; };
          curl = import ./curl.nix { inherit pkgs; };
          goose = import ./goose.nix { inherit pkgs; };
          kernel = kernelStuff.devShell;
        });
    };
}
