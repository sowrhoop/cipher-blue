#!/usr/bin/env bash

set -oue pipefail

dnf5 config-manager addrepo --from-repofile="https://repo.secureblue.dev/secureblue.repo"
rm -f /etc/dnf/protected.d/sudo.conf
dnf5 remove -y nautilus-extensions adobe-mappings-cmap-deprecated adobe-mappings-pdf apr apr-util apr-util-lmdb apr-util-openssl avahi avahi-gobject avahi-tools bind-utils bluez bluez-cups bluez-obexd bolt braille-printer-app brlapi brltty cifs-utils-info cracklib-dicts cups cups-browsed cups-client cups-filters cups-filters-driverless cups-ipptool desktop-backgrounds-gnome dhcp-client dhcp-common djvulibre-libs dnsmasq elfutils-debuginfod-client epiphany-runtime espeak-ng exiv2 fedora-bookmarks fedora-chromium-config fedora-chromium-config-gnome fedora-flathub-remote fedora-repos-archive fedora-third-party fedora-workstation-backgrounds fedora-workstation-repositories ffmpeg-free firefox firefox-langpacks fprintd fprintd-pam freerdp-libs fuse fuse-overlayfs gamemode gawk-all-langpacks gd geolite2-city geolite2-country ghostscript ghostscript-tools-printing git-core-doc gnome-backgrounds gnome-bluetooth gnome-browser-connector gnome-classic-session gnome-color-manager gnome-epub-thumbnailer gnome-remote-desktop gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-common gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list gnome-software gnome-software-rpm-ostree gnome-tour gnome-user-docs gnome-user-share gnome-disk-utility gst-editing-services gstreamer1-plugin-libav gstreamer1-plugins-bad-free gstreamer1-plugins-good-qt gstreamer1-plugins-ugly-free gtkmm3.0 gupnp-av gupnp-dlna gutenprint gutenprint-cups gutenprint-libs gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-smb hplip hplip-common hplip-libs httpd httpd-core httpd-filesystem httpd-tools hunspell-en hyperv-daemons hyperv-daemons-license hypervfcopyd hypervkvpd hypervvssd ibus-anthy ibus-anthy-python ibus-gtk4 ibus-hangul ibus-libpinyin ibus-m17n ibus-typing-booster ImageMagick ImageMagick-libs ipp-usb jbig2dec-libs kernel-modules-extra kernel-tools kernel-tools-libs kpartx langpacks-core-en langpacks-en langpacks-fonts-en langtable leptonica libavc1394 libavdevice-free libavfilter-free libcaca libcupsfilters libdc1394 libdnf5-plugin-expired-pgp-keys libfprint libgee libgphoto2 libgs libhangul libiec61883 libijs libimagequant liblouisutdml-utils libmbim-utils libmediaart libmspack libpaper libpcap libpinyin libpinyin-data libppd libqmi-utils libraqm LibRaw libraw1394 libsane-airscan libsane-hpaio libslirp libsss_certmap libsss_sudo libvncserver libwinpr libwmf-lite libXpm libzip linux-atm-libs lvm2 lvm2-libs m17n-lib mailcap malcontent-control malcontent-ui-libs mod_dnssd mod_http2 mod_lua ModemManager mozilla-filesystem mtr net-snmp-libs NetworkManager-adsl NetworkManager-bluetooth NetworkManager-openconnect NetworkManager-openconnect-gnome NetworkManager-openvpn NetworkManager-openvpn-gnome NetworkManager-ppp NetworkManager-ssh NetworkManager-ssh-gnome NetworkManager-vpnc NetworkManager-vpnc-gnome NetworkManager-wwan nilfs-utils nm-connection-editor noopenh264 ntfs-3g ntfs-3g-system-compression ntfsprogs open-vm-tools open-vm-tools-desktop openconnect opensc opensc-libs openssh-server openvpn orca PackageKit-glib passim pcsc-lite pcsc-lite-ccid pcsc-lite-libs poppler-cpp poppler-utils ppp pulseaudio-utils python-unversioned-command python3-boto3 python3-brlapi python3-click python3-cups python3-enchant python3-langtable python3-louis python3-olefile python3-packaging python3-pexpect python3-pillow python3-pyatspi python3-regex python3-requests python3-speechd python3-urllib3+socks qadwaitadecorations-qt5 qemu-guest-agent qemu-user-static-aarch64 qpdf-libs qrencode-libs qt-settings qt5-filesystem qt5-qtbase qt5-qtbase-common qt5-qtbase-gui qt5-qtdeclarative qt5-qtsvg qt5-qttranslations qt5-qtwayland qt5-qtx11extras qt5-qtxmlpatterns realmd rpm-build-libs rsync rygel samba-client sane-airscan sane-backends sane-backends-drivers-cameras sane-backends-libs slirp4netns sos speech-dispatcher speech-dispatcher-espeak-ng speech-dispatcher-libs speech-dispatcher-utils spice-vdagent spice-webdavd sssd-common sssd-kcm sssd-krb5-common sssd-nfs-idmap sudo-python-plugin system-config-printer-libs system-config-printer-udev systemd-container tar tcl tesseract-libs thermald toolbox totem-video-thumbnailer tuned tuned-ppd udftools unicode-ucd unzip usb_modeswitch usb_modeswitch-data vim-data vim-minimal virtualbox-guest-additions vpnc vpnc-script wget2 wget2-libs wget2-wget words xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xdriinfo xfsprogs yelp yelp-libs yelp-xsl zip
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

# IMA setup runs later via ima-setup.sh (see recipe)
