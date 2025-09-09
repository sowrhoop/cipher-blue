<p align="center">
  <a href="https://github.com/sowrhoop/cipherblue">
    <img src="https://github.com/sowrhoop/cipherblue/blob/main/files/system/usr/share/plymouth/themes/spinner/watermark.png" href="https://github.com/sowrhoop/cipherblue" width=200 />
  </a>
</p>

<h1 align="center">CIPHERBLUE</h1>

[![cipherblue](https://github.com/sowrhoop/cipherblue/actions/workflows/build.yml/badge.svg)](https://github.com/sowrhoop/cipherblue/actions/workflows/build.yml)

## Quick Start

- Install or rebase to the latest image (see Installation).
- First boot: existing USB devices are allowlisted and new devices are blocked (USBGuard).
- Optional privacy mode: `systemctl enable --now cipher-privacy.target`.
- Optional killswitch: edit `/etc/cipherblue/killswitch.conf`, then `systemctl enable --now cipher-killswitch.service`.
- Verify hardening (see Verification).

## Hardened Defaults

- Hardened allocator: preloads `libhardened_malloc.so` globally via `/etc/ld.so.preload`.
- Initramfs hardening: omits FireWire and Thunderbolt (`/etc/dracut.conf.d/99-omitfirewire.conf`, `99-omitthunderbolt.conf`).
- Module lockdown: disables `fs.binfmt_misc` on load via udev (`/etc/udev/rules.d/cipherblue.rules`).
- Network hardening: IPv4/IPv6 forwarding off by default; strict ICMP/TCP; IPv6 privacy; connectivity checks disabled.
- Framebuffer hardening: legacy drivers denied in `/etc/modprobe.d/cipherblue-blacklist.conf`.
- Journald privacy: volatile logs with tight limits (`/etc/systemd/journald.conf.d/60-cipherblue-privacy.conf`).
- Systemd sandboxing: curated drop-ins for core services plus a safe baseline for others.
- USB control: USBGuard blocks new devices after first-boot allowlisting.
- VPN killswitch (opt-in): nftables drops all egress except VPN interfaces.
- Kernel args: strict mitigations, IOMMU hardening, nosmt options, page poisoning, tracing off (applied at build via `files/scripts/kernel-kargs.sh`).

## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First upgrade to latest Fedora version:
  - `rpm-ostree upgrade`
- Reboot to complete the upgrade:
  - `systemctl reboot`
- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  - `rpm-ostree rebase ostree-unverified-registry:ghcr.io/sowrhoop/cipherblue:latest`
- Reboot to complete the rebase:
  - `systemctl reboot`
- Then rebase to the signed image:
  - `rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sowrhoop/cipherblue:latest`
- Reboot again to complete the installation:
  - `systemctl reboot`

The `latest` tag always points to the newest build.

### Kernel Parameter Hardening

Cipherblue applies hardened kernel arguments automatically during build (see `files/scripts/kernel-kargs.sh`). The snippet below is provided for reference or manual usage only:

```
kargs=(
    amd_iommu=force_isolation
    debugfs=off
    efi=disable_early_pci_dma
    extra_latent_entropy
    gather_data_sampling=force
    ia32_emulation=0
    init_on_alloc=1
    init_on_free=1
    intel_iommu=on
    iommu.passthrough=0
    iommu.strict=1
    iommu=force
    ipv6.disable=1
    kvm.nx_huge_pages=force
    l1d_flush=on
    l1tf=full,force
    lockdown=confidentiality
    loglevel=0
    kvm-intel.vmentry_l1d_flush=always
    mds=full,nosmt
    mitigations=auto,nosmt
    module.sig_enforce=1
    nosmt=force
    oops=panic
    page_alloc.shuffle=1
    pti=on
    random.trust_bootloader=off
    random.trust_cpu=off
    randomize_kstack_offset=on
    reg_file_data_sampling=on
    slab_nomerge
    slub_debug=ZF
    spec_rstack_overflow=safe-ret
    spec_store_bypass_disable=on
    spectre_bhi=on
    spectre_v2=on
    tsx=off
    tsx_async_abort=full,nosmt
    vsyscall=none
    page_poison=1
    ftrace=off
    lsm=lockdown,yama,selinux,bpf
)

kargs_str=$(IFS=" "; echo "${kargs[*]}")
rpm-ostree kargs --append-if-missing="$kargs_str" > /dev/null
```

## Privacy Mode

Cipherblue includes an optional privacy mode target that blocks camera/microphone drivers, disables Bluetooth/WWAN radios, and enables the VPN killswitch.

- Enable (persist across reboots):
  - `systemctl enable --now cipher-privacy.target`
- Disable and revert:
  - `systemctl disable --now cipher-privacy.target`
- What it does:
  - Runtime-blacklists modules `uvcvideo`, `snd_usb_audio`, `snd_hda_intel`, `v4l2loopback` in `/run/modprobe.d/cipher-privacy.conf` and attempts to unload them
  - `rfkill block bluetooth` and `rfkill block wwan`
  - Pulls in `cipher-killswitch.service`

## VPN Killswitch (opt-in)

Blocks all outbound traffic except through loopback and allowed VPN interfaces.

- Configure allowed interfaces:
  - Edit `/etc/cipherblue/killswitch.conf` (default: `ALLOWED_IFACES="wg0 tun0 tap0"`).
- Enable/disable:
  - `systemctl enable --now cipher-killswitch.service`
  - `systemctl disable --now cipher-killswitch.service`
- Verify:
  - `nft list table inet cipher_ks`

## USB Device Control

USBGuard is installed and initialized safely on first boot.

- First boot:
  - `cipher-usbguard-setup.service` generates `/etc/usbguard/rules.conf` from currently attached devices and enables `usbguard-daemon`.
- Manage rules:
  - Regenerate: `rm -f /etc/usbguard/rules.conf && systemctl start cipher-usbguard-setup.service`
  - Inspect: `usbguard list-devices`, `usbguard list-rules`

## GNOME Lockdown

- Dconf defaults and locks enforce:
  - Camera/microphone disabled; immediate screen lock with idle lock; no lock-screen notifications; external search providers disabled.
- Portals:
  - GNOME ScreenCast / RemoteDesktop portals disabled (`/usr/share/xdg-desktop-portal/gnome-portals.conf`).
- NetworkManager:
  - Connectivity checks disabled (`/etc/NetworkManager/conf.d/50-disable-connectivity.conf`).
- Tracker indexer:
  - Disabled via dconf with locks.
- Compile dconf database (if adjusting locally):
  - `sudo dconf update`

## Systemd Sandboxing

- Global defaults enable resource accounting, disable core dumps, set sane timeouts for system and user services.
- Curated hardening for core services (drop-ins under `/etc/systemd/system/*/cipherblue.conf`).
- Safe baseline for the rest is generated during build; curated units are excluded from auto-overrides.

Assess a service:
- `systemd-analyze security <unit>`

## Logging Privacy

- Journald stores logs in memory only, with size/retention/rate limits.
- Location: `/etc/systemd/journald.conf.d/60-cipherblue-privacy.conf`

## Kernel and Sysctl Hardening

- Kernel arguments are applied at build via `files/scripts/kernel-kargs.sh`.
- Sysctl: strict ICMP/TCP settings, IPv4/IPv6 forwarding off, io_uring disabled, ptrace/perf restricted, `kernel.kexec_file_load_only=1`.
- `fs.binfmt_misc` is disabled via udev rule when the module appears.

## Verification

- Allocator: `cat /etc/ld.so.preload`
- Kargs: `rpm-ostree kargs | tr ' ' '\n' | sort`
- Journald: `systemd-analyze cat-config systemd/journald.conf`
- Sysctl: `sysctl kernel.io_uring_disabled`, `sysctl net.ipv4.ip_forward`, `sysctl net.ipv6.conf.all.forwarding`
- USBGuard: `systemctl status usbguard-daemon`, `usbguard list-rules`
- Killswitch: `nft list table inet cipher_ks`

## Notes & Opt-Outs

- Hardened allocator: rarely, specific apps may misbehave. To disable system-wide, edit `/etc/ld.so.preload`.
- Thunderbolt/FireWire: if you rely on them at boot, remove the dracut omissions under `/etc/dracut.conf.d/` and rebuild initramfs.
- Connectivity checks: re-enable by deleting `/etc/NetworkManager/conf.d/50-disable-connectivity.conf`.

### Flatpak Hardening

```
flatpak remote-delete --system --force fedora
flatpak remote-delete --system --force fedora-testing
flatpak remote-delete --user --force fedora
flatpak remote-delete --user --force fedora-testing
flatpak remote-delete --system --force flathub
flatpak remote-delete --user --force flathub
flatpak uninstall --delete-data --all -y
rm -rf /var/lib/flatpak/.removed
```

### Fstab Hardening

```
sed -i 's/zstd:1/zstd/g' /etc/fstab

FILE="/etc/fstab"

if ! grep -q 'x-systemd.device-timeout=0,nosuid,noexec,nodev,noatime' "$FILE"; then
    sed -i -e 's/x-systemd.device-timeout=0/x-systemd.device-timeout=0,nosuid,noexec,nodev,noatime/' \
           -e 's/shortname=winnt/shortname=winnt,nosuid,noexec,nodev,noatime/' \
           -e 's/compress=zstd/compress=zstd,nosuid,noexec,nodev,noatime/' \
           -e 's/defaults/defaults,nosuid,noexec,nodev,noatime/' "$FILE"
fi
```

### Microcode Updates

```
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```

### Other Hardening

```
# Cleanup Coredump
ulimit -c 0
systemd-tmpfiles --clean 2> /dev/null
systemctl daemon-reload

echo "coredump cleanup complete."

# Disable System-Tracking
hostnamectl set-hostname host
new_machine_id="b08dfa6083e7567a1921a715000001fb"
echo "$new_machine_id" | tee /etc/machine-id > /dev/null
echo "$new_machine_id" | tee /var/lib/dbus/machine-id > /dev/null

echo "system tracking disabled."

# Block Wireless Devices
rfkill block all
rfkill unblock wifi

# Lockdown Root
passwd -l root

# GNOME Hardening
dconf update

# GRUB Hardening
grub2-setpassword

echo "Hardening complete."
```

### Secure Verified-FOSS Flatpak Repository

```
flatpak remote-add --if-not-exists --user --subset=verified_floss \
  flathub-verified-floss https://dl.flathub.org/repo/flathub.flatpakrepo
```

### SELinux Confined Users (Experimental)

```
semanage login -a -s user_u -r s0 gdm
semanage login -m -s user_u -r s0 __default__
semanage login -m -s sysadm_u -r s0 root
semanage login -a -s sysadm_u -r s0 sysadmin
```

