# nix-dev
Collection of development shells. Usage:
```sh
git clone https://github.com/wasdhjklxyz/nix-dev.git
ln -s nix-dev ~/.config/nix/flakes/nix-dev
nix registry add flake:shells path:$(realpath ~/.config/nix/flakes/nix-dev)
nix develop shells#<dev-shell-name>
```
