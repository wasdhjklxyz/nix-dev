{ pkgs, self, system }:
let
  name = ''\033[33mkernel-dev\033[39m'';
  version = "6.12.67";
  linux = pkgs.stdenv.mkDerivation {
    pname = "linux";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
      hash = "sha256-FoBdxi4fpe+KP0ZvP0Si77FxtSBtaEDO1LpUdc8SxDI=";
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
    buildInputs = with pkgs; [ linux bear socat gdb ];
    shellHook = ''
      NAME="kernel"
      ${builtins.readFile ../nix-develop-stack.sh}

      LINUX_SRC=${linux}
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-kernel-dev"
      ${builtins.readFile ./export-kernel.sh}

      INITRAMFS_SRC=${initramfs}
      ${builtins.readFile ./export-initramfs.sh}

      ${builtins.readFile ./start-qemu.sh}

      BUSYBOX_SRC=${busybox}
      echo "[Versions]"
      echo "  Kernel: ''${LINUX_SRC#*-}"
      echo "  Busybox: ''${BUSYBOX_SRC#*-}"
      echo "[Exported]"
      echo "  KDIR=$KDIR"
      echo "  KERNEL_VERSION=$KERNEL_VERSION"
      echo "  INITRAMFS=$INITRAMFS"
      echo "  VMLINUX=$VMLINUX"
      echo "[Scripts]"
      echo "  start-qemu: Start QEMU using built kernel and initramfs"
      echo "  qemu-tty: Open QEMU ttyS1"
      echo "  cleanup-qemu: Clean up QEMU network interfaces and sockets"
      echo "  debug-qemu: Same as start-qemu but no ASLR and -s -S for QEMU"
      echo "  qemu-gdb: Start GDB for VM started using debug-qemu"
    '';
  };
}
