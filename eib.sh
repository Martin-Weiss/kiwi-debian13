#!/bin/bash
podman run \
	--rm --privileged \
	-v $PWD/eib:/eib:rw,Z \
	registry.suse.com/edge/3.5/edge-image-builder:1.3.3-4.4 \
	generate --definition-file=eib.yaml \
	--output-type tar \
	--output eib.tar \
	--arch x86_64
rm -rf root/oem
mkdir -p root/oem
tar xvf $PWD/eib/eib.tar -C $PWD/root/oem
rm $PWD/eib/eib.tar
sed -i 's/INSTALL/COMBUSTION/g' $PWD/root/oem/combustion/script
sed -i 's/-o ro//g' $PWD/root/oem/combustion/script
