#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -oue pipefail

# Constants
SECUREBLUE_REPO="https://repo.secureblue.dev/secureblue.repo"
APP_ID="${__app_id:-package-hardener}"

echo "Starting system hardening and package optimization..."

# 1. Repository Setup
if ! dnf5 config-manager addrepo --from-repofile="$SECUREBLUE_REPO"; then
    echo "Error: Failed to add secureblue repository." >&2
    exit 1
fi

# 2. Preparation: Remove protection from critical packages we intend to swap/manage
# Warning: Removing sudo.conf from protected.d allows dnf to remove sudo. 
# Ensure your logic replaces it or uses an alternative like 'opendoas'.
rm -f /etc/dnf/protected.d/sudo.conf

# 3. Categorized Removal Logic
# Categorizing helps maintainability and identifies why a package is being removed.

# Network Services (High Attack Surface)
NETWORK_SVCS="avahi avahi-gobject avahi-tools bluez bluez-cups bluez-obexd cups cups-browsed cups-client cups-filters dnsmasq httpd httpd-core mod_dnssd ModemManager nfs-utils samba-client"

# Remote Desktop & Connectivity (Privacy/Security Risk)
CONNECTIVITY="gnome-remote-desktop freerdp-libs spice-vdagent spice-webdavd open-vm-tools open-vm-tools-desktop qemu-guest-agent virtualbox-guest-additions hyperv-daemons"

# Telemetry & Branding (Privacy/Bloat)
TELEMETRY="fedora-bookmarks fedora-third-party fedora-workstation-repositories fedora-flathub-remote gnome-tour gnome-user-docs gnome-user-share yelp yelp-libs"

# Hardware/Biometrics (Attack Surface)
HARDWARE="fprintd fprintd-pam bolt usb_modeswitch"

# Printing/Scanning (Bloat/Attack Surface)
PERIPHERALS="sane-backends sane-airscan hplip gutenprint ghostscript"

# Accessibility/Misc (If not used, these are extra code paths)
MISC="brltty espeak-ng speech-dispatcher orca"

# Consolidate removal list
REMOVE_LIST="$NETWORK_SVCS $CONNECTIVITY $TELEMETRY $HARDWARE $PERIPHERALS $MISC"

echo "Removing high-risk and unnecessary services..."
dnf5 remove -y $REMOVE_LIST

# 4. Installation of Hardening Tools
# We enforce no weak dependencies to keep the system lean.
echo "Installing hardening tools..."
INSTALL_LIST="nautilus trivalent tlp fapolicyd unbound dnscrypt-proxy ima-evm-utils keyutils openssl"
dnf5 install --setopt=install_weak_deps=False --setopt=protected_packages= $INSTALL_LIST -y

# 5. Crypto Policy Enforcement
echo "Configuring System-Wide Crypto Policies..."
if command -v update-crypto-policies >/dev/null 2>&1; then
    # Only set FUTURE if FIPS is not already active/requested
    if [ ! -f /etc/system-fips ] && [ ! -f /etc/cipherblue/fips.enabled ]; then
        update-crypto-policies --set FUTURE || echo "Warning: Failed to set crypto policy to FUTURE."
    fi
fi

# 6. Optional FIPS enablement
if [ -f /etc/cipherblue/fips.enabled ]; then
    echo "Enabling FIPS mode..."
    dnf5 install --setopt=install_weak_deps=False dracut-fips dracut-fips-aesni -y || true
    if command -v fips-mode-setup >/dev/null 2>&1; then
        fips-mode-setup --enable || true
    fi
fi

echo "Hardening script completed successfully."
