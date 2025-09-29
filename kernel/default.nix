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
      export KERNEL_SRC=${linux}/src
      export KERNEL_BUILD=${linux}/build
      export INITRAMFS_BASE=${initramfs}/initramfs.cpio
      export INITRAMFS_FINAL=$PWD/initramfs.cpio
      cp $INITRAMFS_BASE $INITRAMFS_FINAL
      ${builtins.readFile ./add-module.sh}
      ${builtins.readFile ./start-qemu.sh}
    '';
  };
}
