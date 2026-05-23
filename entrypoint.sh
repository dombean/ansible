#!/bin/sh
#
# entrypoint.sh
#
# Docker container entrypoint. If the VAULT_PASS environment variable is set
# (e.g. in CI), it is written to a temporary password file and the Ansible
# playbook runs non-interactively; the temp file is removed on exit so the
# secret never lingers in the container. Otherwise the playbook prompts for the
# vault password interactively (handy for local `docker run -it`).

set -eu

if [ -n "${VAULT_PASS:-}" ]; then
  VAULT_FILE="$(mktemp)"
  trap 'rm -f "$VAULT_FILE"' EXIT
  printf '%s' "$VAULT_PASS" | tr -d ' ' > "$VAULT_FILE"
  ansible-playbook main.yml --vault-password-file="$VAULT_FILE"
else
  ansible-playbook main.yml --ask-vault-pass
fi
