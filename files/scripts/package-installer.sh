#!/usr/bin/env bash
set -oue pipefail

# Install line (unchanged)
dnf5 install --setopt=install_weak_deps=False nautilus trivalent tlp fapolicyd unbound dnscrypt-proxy ima-evm-utils keyutils openssl -y

# Enforce strong system-wide crypto policy
if command -v update-crypto-policies >/dev/null 2>&1; then
  # If FIPS is being enabled, crypto policy will be set to FIPS by the system
  # Skip forcing FUTURE in that case to avoid conflict
  if [ ! -f /etc/system-fips ] && [ ! -f /etc/cipherblue/fips.enabled ]; then
    update-crypto-policies --set FUTURE || true
  fi
fi

# Optional FIPS enablement (controlled by presence of /etc/cipherblue/fips.enabled)
if [ -f /etc/cipherblue/fips.enabled ]; then
  if command -v dnf5 >/dev/null 2>&1; then
    dnf5 install --setopt=install_weak_deps=False dracut-fips dracut-fips-aesni -y || true
  fi
  if command -v fips-mode-setup >/dev/null 2>&1; then
    fips-mode-setup --enable || true
  fi
fi

# Summary of any category failures
if [ "${#failures[@]}" -ne 0 ]; then
  echo "One or more categories failed to remove. Summary:"
  for f in "${failures[@]}"; do
    echo " - $f"
  done
  echo "See logs in: $LOG_DIR"
  exit 1
fi
