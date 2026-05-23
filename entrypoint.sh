#!/bin/sh
#
# entrypoint.sh
#
# Docker container entrypoint used by the CI image. Reads the Ansible Vault
# password from the VAULT_PASS environment variable, writes it to a temporary
# password file, and runs the Ansible playbook against it. The temp file is
# removed on exit so the secret never lingers in the container.

set -eu

# Write the vault password to a temp file and remove it on exit so the
# secret never lingers in the container filesystem.
VAULT_FILE="$(mktemp)"
trap 'rm -f "$VAULT_FILE"' EXIT

printf '%s' "$VAULT_PASS" | tr -d ' ' > "$VAULT_FILE"
ansible-playbook main.yml --vault-password-file="$VAULT_FILE"
