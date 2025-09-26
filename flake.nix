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
      packages =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          kernelVersion = "6.12.49";
        in pkgs.stdenv.mkDerivation {
          fuckshit = {
            pname = "fuckshit";
            version = "0.0.0";

            src = pkgs.fetchgit {
              url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git";
              rev = "linux-rolling-stable";
              hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            };

            buildInputs = with pkgs; [ pkgs.cowsay ];

            buildPhase = ''
              echo "build phase: hi"
            '';

            installPhase = ''
              echo "install phase: hi"
            '';
          };
        };

      devShells = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          go = import ./go.nix { inherit pkgs; };
          cancer = import ./cancer.nix { inherit pkgs; };
          kernel = import ./kernel { inherit self pkgs; };
        });
    };
}
