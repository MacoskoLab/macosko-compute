#/bin/bash

# sudo apt install git -y
# cd /tmp
# git clone https://github.com/mukundraj/macosko-compute
# cd <repo>
# bash ./src/setup-instance.sh

sudo apt update

sudo apt-get -y install podman
sudo apt -y install dbus-x11

sudo apt-get -y install passt
sudo apt-get -y install fdisk htop expect

mkdir -p ~/.config/containers
cp -f ./templates/storage.conf ~/.config/containers/storage.conf

sudo cp -f ./templates/suffix.bashrc.sh /etc/suffix.bashrc

# add a line source('/etc/bashrc_suffix') if line doesnt exist in /etc/bash.bashrc
if ! grep -q "source /etc/suffix.bashrc" /etc/bash.bashrc; then
    sudo echo "source /etc/suffix.bashrc" | sudo tee -a /etc/bash.bashrc
fi

# create file ~/.config/misc/mounts if doesnt exist
mkdir -p ~/.config/misc
if [ ! -f ~/.config/misc/mounts ]; then
    touch ~/.config/misc/mounts
fi

MISC_DIR=./config/misc
sudo mkdir -p $MISC_DIR
sudo touch $MISC_DIR/mounts

MOUNTDIR=/mnt/disks/$(id -un)
sudo mkdir -p $MOUNTDIR


exec bash

# restart
