export INITRAMFS=$PWD/initramfs.cpio

INITRAMFS_BUILD=$(mktemp -d)
mkdir -p $INITRAMFS_BUILD/{bin,sbin,usr/bin,usr/sbin}
cp ${busybox}/bin $INITRAMFS_DIR/bin
cp ${busybox}/sbin $INITRAMFS_DIR/sbin
cp ${busybox}/usr/bin $INITRAMFS_DIR/usr/bin
cp ${busybox}/usr/bin $INITRAMFS_DIR/usr/bin

(cd $INITRAMFS_BUILD && find . | cpio -ov --format=newc) > $INITRAMFS

rm -rf $INITRAMFS_BUILD
