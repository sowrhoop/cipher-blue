#!/usr/bin/env bash
set -oue pipefail
if command -v dconf >/dev/null 2>&1; then
  dconf update || true
fi

