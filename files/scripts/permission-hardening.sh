#!/usr/bin/env bash

set -oue pipefail

chmod 700 /usr/bin/cipher-capabilities
chmod 755 /usr/libexec/cipherblue/remount-run-user
chmod 755 /etc/profile.d/cipherblue_umask.sh
echo "" > /etc/securetty
echo 'UriSchemes=file;https' | tee -a /etc/fwupd/fwupd.conf

umask 077
sed -i 's/^UMASK.*/UMASK 077/g' /etc/login.defs
sed -i 's/^HOME_MODE/#HOME_MODE/g' /etc/login.defs
sed -i 's/umask 022/umask 077/g' /etc/bashrc
sed -i 's/\s+nullok//g' /etc/pam.d/system-auth
sed -i 's@DefaultZone=FedoraWorkstation@DefaultZone=drop@g' /etc/firewalld/firewalld.conf
sed -i 's/nosuid,nodev/nosuid,noexec,nodev/' /usr/lib/systemd/system/dev-hugepages.mount
sed -i 's/nosuid,nodev/nosuid,noexec,nodev/' /usr/lib/systemd/system/tmp.mount
