KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_VERSION%%.*}.x/linux-${KERNEL_VERSION}.tar.xz"
wget "$KERNEL_URL"
