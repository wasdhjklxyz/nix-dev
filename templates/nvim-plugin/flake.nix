{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          neovim-dev-dir = ".nvim-dev";
          neovim-dev = pkgs.writeShellApplication {
            name = "nvim-dev";
            runtimeInputs = with pkgs; [
              git
              neovim
            ];
            runtimeEnv = {
              NVIM_DEV_BIN = "${pkgs.neovim}/bin/nvim";
              NVIM_DEV_CFG = ./repro.lua;
            };
            text = ''
              root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
              export NVIM_DEV_PLUGIN="''${NVIM_DEV_PLUGIN:-$root}"
              dev="$root/${neovim-dev-dir}"
              export XDG_CONFIG_HOME="$dev/config"
              export XDG_DATA_HOME="$dev/data"
              export XDG_STATE_HOME="$dev/state"
              export XDG_CACHE_HOME="$dev/cache"
              exec "$NVIM_DEV_BIN" -u "$NVIM_DEV_CFG" "$@"
            '';
          };
        in
        {
          default = pkgs.mkShell {
            name = "";
            packages = [
              pkgs.lua-language-server
              pkgs.stylua
              neovim-dev
            ];
            inputsFrom = [ ];
            env = { };
            shellHook = ''
              cat > .luarc.json <<'EOF'
              {
                "runtime.version": "LuaJIT",
                "workspace.library": [
                  "${pkgs.neovim-unwrapped}/share/nvim/runtime/lua",
                  "''${3rd}/luv/library",
                  "${neovim-dev-dir}/data/nvim/lazy/lazy.nvim/lua"
                ],
                "workspace.checkThirdParty": false,
                "workspace.ignoreDir": ["${neovim-dev-dir}"]
              }
              EOF
            '';
          };
        }
      );
    };
}
