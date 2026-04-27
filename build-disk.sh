#!/bin/bash

# set variables
TARGET_DIR=.
PROFILE="Disk"
KIWI_IMAGE="registry.suse.com/bci/kiwi:10.2.33-17.3"

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image
podman run --rm --privileged \
-v /var/lib/ca-certificates:/var/lib/ca-certificates \
-v /var/lib/Kiwi/repo:/var/lib/Kiwi/repo \
-v $TARGET_DIR/kiwi.yml:/etc/kiwi.yml \
-v $TARGET_DIR:/image:Z \
$KIWI_IMAGE kiwi-ng \
--profile $PROFILE \
system build \
--allow-existing-root \
--description /image \
--target-dir /image/image \
--ignore-repos-used-for-build \
--add-repo http://deb.debian.org/debian/dists/trixie/main/binary-amd64/
exit

# for build on SMLM
--add-repo file:/var/lib/Kiwi/repo,rpm-dir,common_repo,90,false,false \
--add-bootstrap-package findutils \
--add-bootstrap-package rhn-org-trusted-ssl-cert-osimage \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro61-test-sl-micro-6.1-pool-x86_64-clone/slmicro61-test \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro61-test-sl-micro-extras-6.1-pool-x86_64/slmicro61-test \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro61-test-suse-manager-tools-for-sl-micro-6.1-x86_64/slmicro61-test

# not required for iso building.. 
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
podman run --privileged -v $TARGET_DIR:/image:Z $KIWI_IMAGE kiwi-ng result bundle --target-dir /image/image --bundle-dir=/image/image-bundle --id=0
