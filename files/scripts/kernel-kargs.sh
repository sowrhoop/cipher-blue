#!/usr/bin/env bash

set -oue pipefail

# Append hardened kernel args once, if missing
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
    ima=on
    ima_template=ima-ng
    ima_hash=sha256
    ima_appraise=log
)

if command -v rpm-ostree >/dev/null 2>&1; then
  kargs_str=$(IFS=" "; echo "${kargs[*]}")
  rpm-ostree kargs --append-if-missing="$kargs_str" >/dev/null
  # Enable FIPS mode if configured
  if [ -f /etc/system-fips ] || [ -f /etc/cipherblue/fips.enabled ]; then
    rpm-ostree kargs --append-if-missing=fips=1 >/dev/null || true
  fi
  # Switch IMA appraisal to enforce if opted-in
  if [ -f /etc/cipherblue/ima.enforce ]; then
    rpm-ostree kargs --append-if-missing=ima_appraise=enforce >/dev/null || true
  fi
fi
