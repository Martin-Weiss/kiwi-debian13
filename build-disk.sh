#!/bin/bash

# set variables
TARGET_DIR=.
PROFILE="Disk"
KIWI_IMAGE="registry.suse.com/bci/kiwi:10.2.33-17.3"

VARIANT="boxbuild" # requires local installed kiwi 10.3 + boxbuild plugin
#VARIANT="podman" <- can not work as long as we do not have an image with 10.3 and boxbuild..

DEBIAN="bookworm"
DEBIAN="trixie"

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

if [ "$VARIANT" == "boxbuild" ]; then

# build the image with locally installed kiwi and using boxbuild (qemu)
kiwi --profile $PROFILE \
system boxbuild \
--box ubuntu \
-- \
--description $PWD \
--target-dir $PWD/image \
--ignore-repos-used-for-build \
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_update,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_x86_64,apt-deb,kiwi,,,,,,,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_1",,,,,main,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_2",,,,,contrib,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_3",,,,,non-free,$DEBIAN,false

exit

fi

if [ "$VARIANT" == "podman" ]; then

# build the image with podman
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
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_update,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_x86_64,apt-deb,kiwi,,,,,,,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,trixie_1,,,,,main,trixie,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,trixie_2,,,,,contrib,trixie,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,trixie_3,,,,,non-free,trixie,false
exit

fi

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
