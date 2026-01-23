#!/usr/bin/env bash

set -euo pipefail

ROLE=${1:-client}
SOCK="/tmp/qemu-${ROLE}.sock"

[[ ! -S "$SOCK" ]] && { echo "No QEMU socket at $SOCK" >&2; return 1; }

socat unix-connect:"$SOCK" -,raw,echo=0
