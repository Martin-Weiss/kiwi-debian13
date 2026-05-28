#!/bin/bash
set -ex

#======================================
# Activate services
#--------------------------------------
systemctl enable ssh

#======================================
# Create Mountpoint for combustion and artefacts
#--------------------------------------

mkdir -p /oem

#======================================
# installing here, because I did not find a way to specify the local deb folder as repo 
#--------------------------------------

dpkg -i /deb/combustion_1.5+git8-2.2_all.deb
