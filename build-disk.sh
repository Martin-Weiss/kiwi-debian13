#!/bin/bash

# set variables
TARGET_DIR=.
PROFILE="Disk"
KIWI_BOXES="/data/isos/kiwi_boxes"

#KIWI_IMAGE="registry.suse.com/bci/kiwi:10.2.33-17.3" #official release
#KIWI_IMAGE="registry.suse.de/home/mschaefer/containers_slfo/kiwi:latest" #test release 10.3 with boxbuild support
KIWI_IMAGE="public.ecr.aws/b9k1j9y6/kiwi:latest" #test release 10.3 with boxbuild support

#VARIANT="boxbuild" # requires local installed kiwi 10.3 + boxbuild plugin
VARIANT="podman" #<- can not work as long as we do not have an image with 10.3 and boxbuild.. but works with 10.3 test image with boxbuild support above. Hint: entrypoint added so kiwi-ng / kiwi needs to be removed

#DEBIAN="bookworm"
#DEBIAN_VER="12"

DEBIAN="trixie"
DEBIAN_VER="13"

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image
mkdir -p $KIWI_BOXES

# build the image with locally installed kiwi and using boxbuild (qemu)
if [ "$VARIANT" == "boxbuild" ]; then
kiwi --profile $PROFILE \
system boxbuild \
--box ubuntu \
-- \
--description $PWD \
--target-dir $PWD/image \
--ignore-repos-used-for-build \
--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER"_x86_64",apt-deb,kiwi,,,,,,,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_1",,,,,main,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_2",,,,,contrib,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_3",,,,,non-free,$DEBIAN,false
exit
fi

# build the image with podman <- this is the future target as we do not install and maintain kiwi locally!
if [ "$VARIANT" == "podman" ]; then
podman run --rm --privileged \
-v /var/lib/ca-certificates:/var/lib/ca-certificates \
-v /var/lib/Kiwi/repo:/var/lib/Kiwi/repo \
-v $TARGET_DIR/kiwi.yml:/etc/kiwi.yml \
-v $TARGET_DIR:/image:Z \
-v $KIWI_BOXES:/root/.kiwi_boxes \
$KIWI_IMAGE \
--profile $PROFILE \
system boxbuild \
--box ubuntu -- \
--description /image \
--target-dir /image/image \
--allow-existing-root \
--ignore-repos \
--ignore-repos-used-for-build \
--ca-cert /usr/local/share/ca-certificates/RHN-ORG-TRUSTED-SSL-CERT.crt \
--ca-target-distribution debian \
--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER"_x86_64",apt-deb,kiwi,,,,,,,false \
--add-repo https://susemanager.weiss.ddnss.de/rhn/manager/download,apt-deb,$DEBIAN"_1",,,,,,debian13-test-debian-13-pool-amd64,false \
--add-repo https://susemanager.weiss.ddnss.de/rhn/manager/download,apt-deb,$DEBIAN"_2",,,,,,debian13-test-debian-13-main-updates-amd64,false \
--add-repo https://susemanager.weiss.ddnss.de/rhn/manager/download,apt-deb,$DEBIAN"_3",,,,,,debian13-test-debian-13-main-security-amd64,false \
--add-repo https://susemanager.weiss.ddnss.de/rhn/manager/download,apt-deb,$DEBIAN"_4",,,,,,debian13-test-managertools-debian13-updates-amd64,false
exit
fi

# smlm with authentication (stolen creds from another system) - need to find out how to auto-generate the required creds
#
--add-repo http://susemanager.weiss.ddnss.de:443/rhn/manager/download,apt-deb,$DEBIAN"_1",,,,,,debian13-test-debian-13-pool-amd64,false \
--add-repo http://susemanager.weiss.ddnss.de:443/rhn/manager/download,apt-deb,$DEBIAN"_2",,,,,,debian13-test-debian-13-main-updates-amd64,false \
--add-repo http://susemanager.weiss.ddnss.de:443/rhn/manager/download,apt-deb,$DEBIAN"_3",,,,,,debian13-test-debian-13-main-security-amd64,false \
--add-repo http://susemanager.weiss.ddnss.de:443/rhn/manager/download,apt-deb,$DEBIAN"_4",,,,,,debian13-test-managertools-debian13-updates-amd64,false

# smlm with distribution for non-auth access - does not work, yet - need to find out if that can work at all..
# http://<smlm>/ks/dist/child/<repo>/<distribution>
--add-repo http://susemanager.suse/debian13-test-debian-13-pool-amd64/debian13-test,apt-deb,$DEBIAN"_1",,,,,main,$DEBIAN,false \
--add-repo http://susemanager.suse/debian13-test-debian-13-main-security-amd64/debian13-test,apt-deb,$DEBIAN"_2",,,,,contrib,$DEBIAN,false \
--add-repo http://susemanager.suse/debian13-test-debian-13-main-updates-amd64/debian13-test,apt-deb,$DEBIAN"_3",,,,,non-free,$DEBIAN,false \
--add-repo http://susemanager.suse/debian13-test-managertools-debian13-updates-amd64/debian13-test,apt-deb,$DEBIAN"_3",,,,,non-free,$DEBIAN,false

#upstream:
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_1",,,,,main,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_2",,,,,contrib,$DEBIAN,false \
--add-repo https://ftp.halifax.rwth-aachen.de/debian,apt-deb,$DEBIAN"_3",,,,,non-free,$DEBIAN,false

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
