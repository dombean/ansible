#!/bin/sh

echo $VAULT_PASS | tr -d ' ' > /home/docker/vault_password_file.txt
ansible-playbook main.yml --vault-password-file=/home/docker/vault_password_file.txt
