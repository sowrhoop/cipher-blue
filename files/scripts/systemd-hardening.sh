#!/usr/bin/env bash

set -oue pipefail

services=(
    abrt-journal-core.service
    abrt-oops.service
    abrt-pstoreoops.service
    abrt-vmcore.service
    abrt-xorg.service
    abrtd.service
    alsa-state
    atd.service
    avahi-daemon.service
    avahi-daemon.socket
    cups
    cups-browsed
    debug-shell.service
    emergency.service
    emergency.target
    geoclue
    gssproxy
    httpd
    iscsi-init.service
    iscsi.service
    iscsid.service
    iscsid.socket
    iscsiuio.service
    iscsiuio.socket
    kdump.service
    livesys-late.service
    livesys.service
    low-memory-monitor.service
    mcelog.service
    ModemManager
    multipathd.service
    multipathd.socket
    network-online.target
    nfs-idmapd
    nfs-mountd
    nfs-server
    nfsdcld
    passim.service
    pcscd.service
    pcscd.socket
    remote-fs.target
    rpc-gssd
    rpc-statd
    rpc-statd-notify
    rpcbind
    rpm-ostree-countme.service
    rpm-ostree-countme.timer
    smartd.service
    sshd
    sssd
    sssd-kcm
    tailscaled
    thermald.service
    uresourced.service
    vboxservice.service
    vmtoolsd.service
)

for service in "${services[@]}"; do
        systemctl disable "$service" > /dev/null
        systemctl mask "$service" > /dev/null
done

services=(
    cipher-capabilities
    cipher-cleaner
    cipher-remount
    fstrim.timer
    rpm-ostreed-automatic.timer
    tlp
)

for service in "${services[@]}"; do
        systemctl enable "$service" > /dev/null
done

systemctl --global enable cipher-user-flatpak-updater.service

# Generate sandbox drop-ins for most system services (safe defaults)
units_dir="/usr/lib/systemd/system"
dropin_name="50-cipherblue-sandbox.conf"
exclude_prefixes=(
    "systemd-"
)
# Units too sensitive for generic hardening; use curated drop-ins if needed
exclude_units=(
    "gdm.service"
    "display-manager.service"
    "systemd-udevd.service"
    "systemd-journald.service"
    "systemd-logind.service"
    "systemd-oomd.service"
    "systemd-hostnamed.service"
    "systemd-localed.service"
    "systemd-timedated.service"
    "sshd.service"
    "systemd-resolved.service"
    "dbus-broker.service"
    "polkit.service"
    "chronyd.service"
    "fwupd.service"
    "fwupd-refresh.service"
    "rpm-ostreed.service"
    "NetworkManager.service"
    "wpa_supplicant.service"
    "firewalld.service"
    "unbound.service"
    "fstrim.service"
)

mkdir -p /etc/systemd/system

for unit in "$units_dir"/*.service; do
    [ -e "$unit" ] || continue
    unit_name="$(basename "$unit")"

    # Skip templated units and critical systemd internal units
    if [[ "$unit_name" == *"@.service" ]]; then
        continue
    fi
    skip=false
    for p in "${exclude_prefixes[@]}"; do
        if [[ "$unit_name" == "$p"* ]]; then
            skip=true
            break
        fi
    done
    for u in "${exclude_units[@]}"; do
        if [[ "$unit_name" == "$u" ]]; then
            skip=true
            break
        fi
    done
    if $skip; then
        continue
    fi

    d="/etc/systemd/system/${unit_name}.d"
    # If a curated drop-in already exists, skip auto drop-in to avoid conflicts
    if [ -d "$d" ] && ls "$d"/*.conf >/dev/null 2>&1; then
        continue
    fi
    mkdir -p "$d"
    cat >"$d/$dropin_name" <<'EOF'
[Service]
# Minimal baseline unlikely to break services; curated drop-ins handle more.
NoNewPrivileges=yes
PrivateTmp=yes
ProtectClock=true
ProtectControlGroups=true
RestrictRealtime=true
SystemCallArchitectures=native
UMask=0077
EOF
done
