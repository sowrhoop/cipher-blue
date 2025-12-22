#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -oue pipefail

# Constants
SECUREBLUE_REPO="https://repo.secureblue.dev/secureblue.repo"

echo "Starting system hardening and 'sudo' removal..."

# 1. Repository Setup
if ! dnf5 config-manager addrepo --from-repofile="$SECUREBLUE_REPO"; then
    echo "Error: Failed to add secureblue repository." >&2
    exit 1
fi

# 2. Preparation: Unlock protected packages
# We must remove the protection config to allow dnf5 to actually uninstall sudo.
rm -f /etc/dnf/protected.d/sudo.conf

# 3. Categorized Removal Logic
# Including 'sudo' and its python plugins in the removal list.
NETWORK_SVCS="avahi avahi-gobject avahi-tools bluez bluez-cups bluez-obexd cups cups-browsed cups-client cups-filters dnsmasq httpd httpd-core mod_dnssd ModemManager nfs-utils samba-client"
CONNECTIVITY="gnome-remote-desktop freerdp-libs spice-vdagent spice-webdavd open-vm-tools open-vm-tools-desktop qemu-guest-agent virtualbox-guest-additions hyperv-daemons"
TELEMETRY="fedora-bookmarks fedora-third-party fedora-workstation-repositories fedora-flathub-remote gnome-tour gnome-user-docs gnome-user-share yelp yelp-libs"
HARDWARE="fprintd fprintd-pam bolt usb_modeswitch"
PERIPHERALS="sane-backends sane-airscan hplip gutenprint ghostscript"
MISC="brltty espeak-ng speech-dispatcher orca"

# THE BIG REMOVAL: Adding sudo and libsss_sudo
SUDO_REMOVAL="sudo sudo-python-plugin libsss_sudo"

REMOVE_LIST="$NETWORK_SVCS $CONNECTIVITY $TELEMETRY $HARDWARE $PERIPHERALS $MISC $SUDO_REMOVAL"

echo "Removing packages and legacy 'sudo' access..."
dnf5 remove -y $REMOVE_LIST

# 4. Installation of Hardening Tools
# install_weak_deps=False ensures we don't accidentally pull sudo back in as a dependency.
echo "Installing hardening tools..."
INSTALL_LIST="nautilus trivalent tlp fapolicyd unbound dnscrypt-proxy ima-evm-utils keyutils openssl"
dnf5 install --setopt=install_weak_deps=False --setopt=protected_packages= $INSTALL_LIST -y

# 5. Crypto Policy Enforcement
echo "Configuring System-Wide Crypto Policies..."
if command -v update-crypto-policies >/dev/null 2>&1; then
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

echo "Hardening script completed. System is now 'sudo-less'."
