export INITRAMFS=$PWD/initramfs.cpio

INITRAMFS_BUILD=$(mktemp -d)
mkdir -p $INITRAMFS_BUILD/bin
cp $BUSYBOX_DIR/bin/* $INITRAMFS_BUILD/bin

(cd $INITRAMFS_BUILD && find . | cpio -ov --format=newc) > $INITRAMFS

rm -rf $INITRAMFS_BUILD
