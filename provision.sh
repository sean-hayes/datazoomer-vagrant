#!/bin/bash

# system updates
sudo apt-get -y update
sudo apt-get -y install git bash

# setup base permissions
sudo addgroup admin
sudo addgroup dev
echo "%admin ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/admin_conf
sudo chmod 0440 /etc/sudoers.d/admin_conf
sudo adduser vagrant admin
sudo adduser vagrant dev
