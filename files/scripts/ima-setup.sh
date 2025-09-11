#!/usr/bin/env bash
set -euo pipefail

# Generate IMA X.509 keypair, sign executables under /usr, install public cert
# The private key is removed after signing to avoid shipping it in the image.

KEYDIR=/etc/keys/ima
CRT=$KEYDIR/ima.crt
KEY=$KEYDIR/ima.key
DER=$KEYDIR/ima.der

install -d -m 0700 "$KEYDIR"

if [ ! -f "$DER" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes \
    -subj "/CN=CipherBlue IMA/" \
    -keyout "$KEY" -out "$CRT" -days 3650 -sha256
  openssl x509 -in "$CRT" -outform der -out "$DER"
fi

# Sign root-owned files across core system directories to satisfy fowner=0 appraisal
if command -v evmctl >/dev/null 2>&1; then
  declare -a roots=(/usr /lib /lib64 /bin /sbin)
  for root in "${roots[@]}"; do
    [ -d "$root" ] || continue
    mapfile -t files < <(find "$root" -xdev -type f -user root -print)
    if ((${#files[@]})); then
      for f in "${files[@]}"; do
        evmctl ima_sign -a sha256 -k "$KEY" "$f" || true
      done
    fi
  done
fi

# Remove private key from the image
shred -u -z "$KEY" || rm -f "$KEY" || true

exit 0
