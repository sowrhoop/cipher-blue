#!/usr/bin/env bash
set -oue pipefail

# add repo & housekeeping (unchanged)
dnf5 config-manager addrepo --from-repofile="https://repo.secureblue.dev/secureblue.repo"
rm -f /etc/dnf/protected.d/sudo.conf

# Categorized removal command (same packages as original, only reorganized)
dnf5 remove -y \
  # --- Desktop / GNOME / Shell ---
  nautilus-extensions \
  desktop-backgrounds-gnome \
  fedora-bookmarks \
  fedora-workstation-backgrounds \
  gnome-backgrounds \
  gnome-classic-session \
  gnome-color-manager \
  gnome-tour \
  gnome-user-docs \
  gnome-user-share \
  gnome-disk-utility \
  gnome-software \
  gnome-software-rpm-ostree \
  gnome-remote-desktop \
  gnome-browser-connector \
  epiphany-runtime \
  firefox \
  firefox-langpacks \
  mozilla-filesystem \
  fedora-chromium-config \
  fedora-chromium-config-gnome \
  fedora-flathub-remote \
  fedora-repos-archive \
  fedora-third-party \
  fedora-workstation-repositories \
  gnome-epub-thumbnailer \
  gnome-shell-extension-apps-menu \
  gnome-shell-extension-background-logo \
  gnome-shell-extension-common \
  gnome-shell-extension-launch-new-instance \
  gnome-shell-extension-places-menu \
  gnome-shell-extension-window-list \
  qadwaitadecorations-qt5 \
  qt-settings \
  qt5-filesystem \
  qt5-qtbase \
  qt5-qtbase-common \
  qt5-qtbase-gui \
  qt5-qtdeclarative \
  qt5-qtsvg \
  qt5-qttranslations \
  qt5-qtwayland \
  qt5-qtx11extras \
  qt5-qtxmlpatterns \
  gtkmm3.0 \
  xcb-util-image \
  xcb-util-keysyms \
  xcb-util-renderutil \
  xcb-util-wm \
  xdriinfo \
  yelp \
  yelp-libs \
  yelp-xsl \
  nautilus-extensions
  
dnf5 remove -y \
  # --- Printing / Scanning ---
  cups \
  cups-browsed \
  cups-client \
  cups-filters \
  cups-filters-driverless \
  cups-ipptool \
  ghostscript \
  ghostscript-tools-printing \
  gutenprint \
  gutenprint-cups \
  gutenprint-libs \
  hplip \
  hplip-common \
  hplip-libs \
  libcupsfilters \
  libppd \
  libpaper \
  ipp-usb \
  system-config-printer-libs \
  system-config-printer-udev \
  sane-airscan \
  sane-backends \
  sane-backends-drivers-cameras \
  sane-backends-libs \
  libsane-airscan \
  libsane-hpaio \
  tesseract-libs \
  gutenprint-libs

dnf5 remove -y \
  # --- Multimedia / Audio / Video / GStreamer ---
  ffmpeg-free \
  gst-editing-services \
  gstreamer1-plugin-libav \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-good-qt \
  gstreamer1-plugins-ugly-free \
  ImageMagick \
  ImageMagick-libs \
  totem-video-thumbnailer \
  pulseaudio-utils \
  libavc1394 \
  libavdevice-free \
  libavfilter-free \
  libraw1394 \
  LibRaw \
  libimagequant \
  libwmf-lite \
  libgs \
  rygel \
  gupnp-av \
  gupnp-dlna \
  qpdf-libs \
  qrencode-libs \
  exiv2 \
  djvulibre-libs \
  gvfs-gphoto2 \
  libgphoto2 \
  libmediaart \
  leptonica

dnf5 remove -y \
  # --- Browsers / Web / Networking tools ---
  bind-utils \
  dnsmasq \
  dhcp-client \
  dhcp-common \
  mtr \
  net-snmp-libs \
  rsync \
  wget2 \
  wget2-libs \
  wget2-wget \
  curl

dnf5 remove -y \
  # --- NetworkManager / VPN / Remote access ---
  NetworkManager-adsl \
  NetworkManager-bluetooth \
  NetworkManager-openconnect \
  NetworkManager-openconnect-gnome \
  NetworkManager-openvpn \
  NetworkManager-openvpn-gnome \
  NetworkManager-ppp \
  NetworkManager-ssh \
  NetworkManager-ssh-gnome \
  NetworkManager-vpnc \
  NetworkManager-vpnc-gnome \
  NetworkManager-wwan \
  nm-connection-editor \
  openvpn \
  openconnect \
  slirp4netns \
  open-vm-tools \
  open-vm-tools-desktop \
  qemu-guest-agent \
  qemu-user-static-aarch64 \
  spice-vdagent \
  spice-webdavd \
  samba-client \
  smbclient

dnf5 remove -y \
  # --- Virtualization & Containers ---
  virtualbox-guest-additions \
  toolbox \
  systemd-container \
  fuse \
  fuse-overlayfs \
  slirp4netns \
  open-vm-tools \
  open-vm-tools-desktop \
  qemu-guest-agent \
  qemu-user-static-aarch64

dnf5 remove -y \
  # --- Hardware / Modems / Bluetooth / USB ---
  bluez \
  bluez-cups \
  bluez-obexd \
  ModemManager \
  usb_modeswitch \
  usb_modeswitch-data \
  libmbim-utils \
  libqmi-utils \
  libpcap \
  libvncserver \
  libwinpr \
  libiec61883 \
  libavc1394 \
  libdc1394 \
  libraw1394 \
  ipp-usb \
  bolt \
  hyperv-daemons \
  hyperv-daemons-license \
  hypervfcopyd \
  hypervkvpd \
  hypervvssd

dnf5 remove -y \
  # --- Accessibility / Input / IBus / Speech / Braille ---
  braille-printer-app \
  brlapi \
  brltty \
  orca \
  speech-dispatcher \
  speech-dispatcher-espeak-ng \
  speech-dispatcher-libs \
  speech-dispatcher-utils \
  espeak-ng \
  fprintd \
  fprintd-pam \
  libfprint \
  python3-brlapi \
  python3-pyatspi \
  python3-louis \
  liblouisutdml-utils \
  ibus-anthy \
  ibus-anthy-python \
  ibus-gtk4 \
  ibus-hangul \
  ibus-libpinyin \
  ibus-m17n \
  ibus-typing-booster \
  orca

dnf5 remove -y \
  # --- System services / Daemons / HTTP ---
  httpd \
  httpd-core \
  httpd-filesystem \
  httpd-tools \
  mod_dnssd \
  mod_http2 \
  mod_lua \
  realmd \
  PackageKit-glib \
  sos \
  passim \
  mtr \
  rsync

dnf5 remove -y \
  # --- System & Kernel tools / Storage / LVM / Filesystems ---
  kpartx \
  lvm2 \
  lvm2-libs \
  kernel-modules-extra \
  kernel-tools \
  kernel-tools-libs \
  xfsprogs \
  ntfs-3g \
  ntfs-3g-system-compression \
  ntfsprogs \
  nilfs-utils \
  udftools \
  tar \
  unzip \
  zip \
  ppp \
  slirp4netns

dnf5 remove -y \
  # --- Security / Auth / SSSD / SSH / PAM / PKI ---
  sssd-common \
  sssd-kcm \
  sssd-krb5-common \
  sssd-nfs-idmap \
  libsss_certmap \
  libsss_sudo \
  openssh-server \
  sudo-python-plugin \
  cracklib-dicts \
  libdnf5-plugin-expired-pgp-keys \
  realmd \
  openconnect \
  openvpn

dnf5 remove -y \
  # --- Libraries (misc low-level libraries) ---
  apr \
  apr-util \
  apr-util-lmdb \
  apr-util-openssl \
  libcaca \
  libijs \
  libmspack \
  libzip \
  libgee \
  libimagequant \
  libmbim-utils \
  libmediaart \
  libqmi-utils \
  libslirp \
  libwmf-lite \
  libgs \
  libhangul \
  libfprint \
  libXpm \
  libppd \
  libpaper \
  libraw1394 \
  libavc1394 \
  libdnf5-plugin-expired-pgp-keys \
  libraqm \
  LibRaw

dnf5 remove -y \
  # --- Language packs / Spell / Fonts / Locale ---
  langpacks-core-en \
  langpacks-en \
  langpacks-fonts-en \
  hunspell-en \
  langtable \
  gawk-all-langpacks \
  python3-langtable \
  unicode-ucd \
  words

dnf5 remove -y \
  # --- Python & runtime packages ---
  python-unversioned-command \
  python3-boto3 \
  python3-click \
  python3-cups \
  python3-enchant \
  python3-olefile \
  python3-packaging \
  python3-pexpect \
  python3-pillow \
  python3-regex \
  python3-requests \
  python3-speechd \
  python3-urllib3+socks \
  python3-brlapi \
  python3-pyatspi \
  python3-louis \
  python3-langtable

dnf5 remove -y \
  # --- Developer / Build / Tools / CLI ---
  git-core-doc \
  rpm-build-libs \
  rsync \
  tar \
  unzip \
  vim-data \
  vim-minimal \
  qpdf-libs \
  qrencode-libs \
  libcaca \
  gd \
  mtr \
  sos \
  thermald \
  tuned \
  tuned-ppd \
  mod_http2 \
  mod_lua \
  passim

dnf5 remove -y \
  # --- Smart card / PC/SC / Security tokens ---
  pcsc-lite \
  pcsc-lite-ccid \
  pcsc-lite-libs \
  opensc \
  opensc-libs \
  pcsc-lite \
  pcsc-lite-ccid \
  pcsc-lite-libs

dnf5 remove -y \
  # --- Printing/Office helpers / Poppler / PDF ---
  poppler-cpp \
  poppler-utils \
  qpdf-libs \
  ghostscript \
  ghostscript-tools-printing \
  exiv2 \
  djvulibre-libs

dnf5 remove -y \
  # --- Misc utilities & extras (remaining miscellaneous packages) ---
  cifs-utils-info \
  gawk-all-langpacks \
  gd \
  geolite2-city \
  geolite2-country \
  gamemode \
  ImageMagick-libs \
  ipp-usb \
  jbig2dec-libs \
  libcaca \
  libgphoto2 \
  libmbim-utils \
  libmspack \
  libpcap \
  mailcap \
  malcontent-control \
  malcontent-ui-libs \
  mod_dnssd \
  mozilla-filesystem \
  net-snmp-libs \
  nilfs-utils \
  noopenh264 \
  open-vm-tools \
  open-vm-tools-desktop \
  passim \
  ppp \
  pulseaudio-utils \
  qadwaitadecorations-qt5 \
  realmd \
  rygel \
  samba-client \
  slirp4netns \
  sos \
  spice-vdagent \
  spice-webdavd \
  sudo-python-plugin \
  systemd-container \
  tcl \
  thermald \
  toolbox \
  totem-video-thumbnailer \
  udftools \
  unicode-ucd \
  usb_modeswitch \
  usb_modeswitch-data \
  virtualbox-guest-additions \
  vpnc \
  vpnc-script \
  wget2-wget \
  words \
  xfsprogs \
  zip

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

# IMA setup runs later via ima-setup.sh (see recipe)
