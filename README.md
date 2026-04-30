Kiwi build for Debian 13
-------------------------------

Current state - probably some things are wrong... ;-)

On SMLM enable Debian 13 replication.
Make sure you have sufficient disk space available.
Replicate
Create lifecycle an stage
Create distribution
Create activation key

Create kiwi xml and config.sh

We can not set locale and keytable for debian 13 via xml - if required we can do it in config.sh
So disabled these in the xml:
<locale>en_US</locale>
<keytable>us</keytable>
same problem might be there for timezone in some cases.

Run the build with the repos from SMLM.

We could build with a debian system that has kiwi 10.3 installed.
Or we can build on SLES.

We have to use kiwi 10.3 for debian - which is not available as container.
-> get it from https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/SLFO/

When building on SLES - we have to use boxbuild as the kiwi image we can use via podman does not support debian.
https://osinside.github.io/kiwi/plugins/self_contained.html
-> this needs python3-kiwi_boxed_plugin
Hint: boxbuild uses https://github.com/OSInside/kiwi-boxed-plugin/blob/main/kiwi_boxed_plugin/config/kiwi_boxed_plugin.yml

This depends on python313-progressbar2
-> get it from https://download.opensuse.org/repositories/devel:/languages:/python:/backports/16.0/

Remove the repos from the kiwi xml as we need to add them depending on the stage we are building for..

For repos we need to add (or 13 in Builder instead of Staging)
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_update,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Staging/Debian_12_x86_64,apt-deb,kiwi,,,,,,,false \

--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER,apt-deb,kiwi,,,,,,,false \
--add-repo obs://Virtualization:Appliances:Builder/"Debian_"$DEBIAN_VER"_x86_64",apt-deb,kiwi,,,,,,,false \

for the iso build as we need a few packages for dracut
or the corresponding versions.. see build*.sh

To register against SMLM
------------------------

ssh into the box as mweiss
su -
hostnamectl hostname debian13-1.suse

For auto-sign-in to SMLM set the autosign grains and run bootstrap with the right activation key:

mkdir -p /etc/venv-salt-minion/minion.d/

cat <<EOF > /etc/venv-salt-minion/minion.d/autosign-grains.conf
grains:
    autosign_key: 4fea9511-8b25-4f7a-9071-8eb06c07bad0
autosign_grains:
    - autosign_key
EOF
curl http://susemanager.suse/pub/bootstrap/bootstrap.sh -o bootstrap.sh
ACTIVATION_KEYS=1-debian13-test bash bootstrap.sh


On SUSE Multi-Linux Manager:
----------------------------

Enable autosign:

mgrctl term
echo "autosign_grains_dir: /etc/salt/autosign_grains" > /etc/salt/master.d/autosign_grains.conf
mkdir -p /etc/salt/autosign_grains
echo "4fea9511-8b25-4f7a-9071-8eb06c07bad0" > /etc/salt/autosign_grains/autosign_key
systemctl restart salt-master
exit

ToDo / next steps:

- get build done with frozen SMLM channels
- get personalization added - maybe see if combustion can work
- see how we can add the boxbuild feature to SMLM (idea is to detect the OS in the kiwi xml and then select the right box for the right build...)
