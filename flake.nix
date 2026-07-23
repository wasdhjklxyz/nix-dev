{
  description = "Collection of development shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      rust-overlay,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      nixosModules.qemu-lab = import ./qemu/qemu-lab.nix;
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          kernelStuff = import ./kernel { inherit pkgs self system; };
        in
        {
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
          sops = import ./sops.nix { inherit pkgs; };
          age = import ./age.nix { inherit pkgs; };
          i686 = import ./i686.nix { inherit nixpkgs; };
          java = import ./java.nix { inherit pkgs; };
          vnc = import ./vnc.nix { inherit pkgs; };
          qgc = import ./qgc.nix { inherit pkgs; };
          recon = import ./recon.nix { inherit pkgs; };
          mosquitto = import ./mosquitto.nix { inherit pkgs; };
          bear = import ./bear.nix { inherit pkgs; };
          mission-planner = import ./mission-planner.nix { inherit pkgs; };
          pixiecore = import ./pixiecore.nix { inherit pkgs; };
          rust = import ./rust.nix { inherit pkgs; };
          lua = import ./lua.nix { inherit pkgs; };
        }
      );

      templates = {
        nvim-plugin = {
          path = ./templates/nvim-plugin;
          description = "Neovim plugin dev shell";
        };
      };
    };
}
