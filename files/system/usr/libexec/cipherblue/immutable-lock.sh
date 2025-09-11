#!/usr/bin/env bash
set -euo pipefail

lock_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    chattr +i "$f" 2>/dev/null || true
  fi
}

# Lock critical configuration to prevent tampering at runtime.
lock_file /etc/security/access.conf
for f in /etc/polkit-1/rules.d/*.rules; do lock_file "$f"; done
lock_file /etc/ssh/ssh_config.d/10-cipherblue.conf
lock_file /etc/ssh/sshd_config.d/10-cipherblue.conf
lock_file /etc/sysctl.d/60-cipherblue-hardening.conf
lock_file /etc/systemd/logind.conf.d/50-killuser.conf
lock_file /etc/systemd/journald.conf.d/60-cipherblue-privacy.conf
lock_file /etc/NetworkManager/conf.d/60-cipherblue.conf
lock_file /etc/NetworkManager/conf.d/99-disable-connectivity.conf
lock_file /etc/unbound/unbound.conf
lock_file /etc/containers/policy.json
lock_file /etc/ld.so.preload

exit 0

