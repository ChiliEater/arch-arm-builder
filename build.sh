#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MIRROR=uk.mirror.archlinuxarm.org
IMAGE=ArchLinuxARM-aarch64-latest.tar.gz
SIG=ArchLinuxARM-aarch64-latest.tar.gz.sig
ISO=$(echo $IMAGE | sed "s/\.tar\.gz/\.iso/g")
MOUNT=$SCRIPT_DIR/mnt

#if fuse-archive ; then
#    echo "fuse-archive: OK"
#else
#    echo "fuse-archive is not installed or not available."
#    echo "https://github.com/google/fuse-archive"
#    exit 1
#fi
#
#if genisoimage ; then
#    echo "genisoimage: OK"
#else
#    echo "genisoimage is not installed or not available."
#    echo 
#    exit 1
#fi

echo "Creating mount point"
mkdir $MOUNT

gpg --recv-key 77193F152BDBE6A6

echo "Cleaning $SCRIPT_DIR/$IMAGE..."
rm $SCRIPT_DIR/$IMAGE > /dev/null
echo "Cleaning $SCRIPT_DIR/$SIG..."
rm $SCRIPT_DIR/$SIG > /dev/null

wget https://$MIRROR/os/$IMAGE
wget https://$MIRROR/os/$SIG

if gpg --verify $SCRIPT_DIR/$SIG $SCRIPT_DIR/$IMAGE ; then
    echo "Signature check successful!"
else
    echo "Signature check failed! Aborting."
    exit 1
fi

dd if=/dev/zero of=arch.iso bs=1M iflag=fullblock count=1024 && sync
sudo mount -o loop $ISO $MOUNT
sudo bsdtar -xpf $IMAGE -C $MOUNT