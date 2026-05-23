#!/bin/bash
#
# setup.sh
#
# Bootstrap script for a fresh Ubuntu machine. Installs Ansible (and git) from
# the official PPA, clones this repository into ~/ansible_ubuntu_install (if not
# already present), and runs the playbook with prompts for the become and vault
# passwords. Any extra arguments are forwarded to ansible-playbook.

# echo every command and exit if any command fails
set -ex

sudo apt-get update
sudo apt-get install --yes software-properties-common

sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes ansible

sudo apt-get install --yes git

# clone repository if not already cloned
if [ -d ~/ansible_ubuntu_install ]; then
  echo "$HOME/ansible_ubuntu_install already cloned! Make sure it is a clone of: https://github.com/dombean/ansible"
else
  git clone https://github.com/dombean/ansible ~/ansible_ubuntu_install
fi

cd ~/ansible_ubuntu_install || exit 1

ansible-playbook main.yml --ask-become-pass --ask-vault-pass "$@"

echo "Log out and back in for shell changes to take effect"
