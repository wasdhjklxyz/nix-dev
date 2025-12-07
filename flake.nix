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
          sqlite = import ./sqlite.nix { inherit pkgs; };
          cmake = import ./cmake.nix { inherit pkgs; };
          curl = import ./curl.nix { inherit pkgs; };
          goose = import ./goose.nix { inherit pkgs; };
          python = import ./python.nix { inherit pkgs; };
          kernel = kernelStuff.devShell;
          valgrind = import ./valgrind.nix { inherit pkgs; };
          nasm = import ./nasm.nix { inherit pkgs; };
          gdb = import ./gdb.nix { inherit pkgs; };
          qemu = import ./qemu { inherit pkgs; };
          afl = import ./afl { inherit pkgs; };
          malanal = import ./malanal { inherit pkgs; };
          latex = import ./latex.nix { inherit pkgs; };
        });
    };
}
