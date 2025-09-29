{ pkgs, self, system }:
let
  name = ''\033[33mkernel-dev\033[39m'';
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
    postPatch = "patchShebangs scripts/config";
    configurePhase = builtins.readFile ./configure.sh;
    buildPhase = builtins.readFile ./build.sh;
    installPhase = builtins.readFile ./install.sh;
    dontFixup = true;
    dontStrip = true;
    dontPatchELF = true;
    dontPatchShebangs = true;
  };
  busybox = pkgs.busybox.override {
    enableStatic = true;
  };
  initramfs = pkgs.stdenv.mkDerivation {
    pname = "initramfs";
    version = "0.0";  # TODO: Automatic versioning?
    dontUnpack = true;
    buildInputs = [ busybox ];
    buildPhase = ''
      BUSYBOX_BIN=${busybox}/bin/busybox
      ${builtins.readFile ./initramfs-build.sh}
    '';
    installPhase = builtins.readFile ./initramfs-install.sh;
  };
in {
  packages = { inherit linux busybox initramfs; };
  devShell = pkgs.mkShell {
    buildInputs = with pkgs; [ linux busybox ];
    shellHook = ''
      if [[ -n "$NIX_DEVELOP_STACK" ]]; then
        export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|${name}"
      else
        export NIX_DEVELOP_STACK="${name}"
      fi
      export PS1="\n\033[1m[$NIX_DEVELOP_STACK]\033[0m $PS1"

      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-kernel-dev"

      LINUX_SRC=${linux}
      ${builtins.readFile ./export-kernel.sh}

      INITRAMFS_SRC=${initramfs}
      ${builtins.readFile ./export-initramfs.sh}

      ${builtins.readFile ./initramfs-modules.sh}
      ${builtins.readFile ./start-qemu.sh}

      BUSYBOX_SRC=${busybox}
      echo "[Versions]"
      echo "  Kernel: ''${LINUX_SRC#*-}"
      echo "  Busybox: ''${BUSYBOX_SRC#*-}"
      echo "[Exported]"
      echo "  KDIR=$KDIR"
      echo "  KERNEL_VERSION=$KERNEL_VERSION"
      echo "  INITRAMFS=$INITRAMFS"
      echo "[Scripts]"
      echo "  add-module: Add module to initramfs"
      echo "  reset-modules: Remove all modules from initramfs"
      echo "  start-qemu: Start QEMU using built kernel and initramfs"
    '';
  };
}
