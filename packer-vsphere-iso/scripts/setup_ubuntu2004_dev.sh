#!/bin/bash -eux

# Intention of this script is to load packages that are common to a development environment.
# This script could be split up into individual scripts if needed but for now this seems to be 
# like a good method of creating a 'base' configuration.
# Script requires sudo

# Set debian frontend to non interactive: man 7 debconf
export env DEBIAN_FRONTEND="noninteractive"

# Update repository.
echo "#---"
echo "#--- Upgrade base Ubuntu Server packages"
echo "#---"
apt-get -y update
apt-get -y upgrade

# Install Desktop.
echo "#---"
echo "#--- Install and Configure Ubuntu Desktop"
echo "#---"
apt-get -y install ubuntu-desktop

# Install Common Developer Tools - Snap
echo "#---"
echo "#--- Install Visual Studio Code"
echo "#---"
snap install --classic code
echo "#---"
echo "#--- Install Postman"
echo "#---"
snap install postman

# Install Google Chrome
echo "#---"
echo "#--- Install Google Chrome"
echo "#---"
export env APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get -y update
apt-get -y install google-chrome-stable

# Install Docker
echo "#---"
echo "#--- Install Docker"
echo "#---"
apt-get -y update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io
docker run hello-world
usermod -aG docker $USER

# Install Ansible.
echo "#---"
echo "#--- Install Ansible"
echo "#---"

apt-get -y update && apt-get -y upgrade
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get -y update
apt-get -y install ansible

# Change network management from netplan to Network Manager
echo "#---"
echo '#--- Convert network management to the desktop GUI'
echo "#---"
echo 'Enable Network Manager to manage'
cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.orig 
sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
service network-manager restart

echo 'Ensure networks are managed by NetworkManager'
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.orig
sed -i '/network:/a \ \ renderer: NetworkManager' /etc/netplan/00-installer-config.yaml
netplan apply

echo "#---"
echo '#--- The Ubuntu 20.04 Developers Desktop Global Setup Applied!!!'
echo "#---"
