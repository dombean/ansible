#!/bin/bash

# echo every command and exit if any command fails
set -ex

sudo apt-get update
sudo apt-get install --yes software-properties-common

sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes ansible

sudo apt-get install --yes git

# clone repository if not already cloned
if [ -d ~/ansible_ubuntu_install ]; then
  echo "$HOME/ansible_ubuntu_install already cloned! Make sure it is a clone of: http://github.com/dombean/ansible_ubuntu_install.git"
else
  git clone http://github.com/dombean/ansible_ubuntu_install.git ~/ansible_ubuntu_install
fi

cd ~/ansible_ubuntu_install

ansible-playbook main.yml --ask-become-pass --ask-vault-pass "$@"

echo ""Log out and back in for shell changes to take effect"
