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
        });
    };
}
