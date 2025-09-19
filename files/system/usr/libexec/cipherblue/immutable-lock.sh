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
# Lock SSH client/server policy drop-ins
for f in /etc/ssh/ssh_config.d/*.conf; do lock_file "$f"; done
for f in /etc/ssh/sshd_config.d/*.conf; do lock_file "$f"; done
lock_file /etc/sysctl.d/60-cipherblue-hardening.conf
lock_file /etc/systemd/logind.conf.d/50-killuser.conf
lock_file /etc/systemd/journald.conf.d/60-cipherblue-privacy.conf
lock_file /etc/NetworkManager/conf.d/60-cipherblue.conf
lock_file /etc/NetworkManager/conf.d/99-disable-connectivity.conf
lock_file /etc/unbound/unbound.conf
lock_file /etc/containers/policy.json
lock_file /etc/ld.so.preload
lock_file /etc/default/useradd
# Kernel module hardening
lock_file /etc/modprobe.d/99-cipherblue-hardening.conf
# Network egress policy
lock_file /etc/cipherblue/killswitch.conf
# USB and execution control
lock_file /etc/usbguard/usbguard-daemon.conf
lock_file /etc/usbguard/rules.conf
lock_file /etc/fapolicyd/fapolicyd.conf
for f in /etc/fapolicyd/rules.d/*.rules; do lock_file "$f"; done
# Local TTY control
lock_file /etc/securetty
# Firewalld zone overrides
lock_file /etc/firewalld/zones/FedoraWorkstation.xml

exit 0
