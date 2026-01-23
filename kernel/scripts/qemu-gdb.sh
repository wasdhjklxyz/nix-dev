#!/usr/bin/env bash

set -euo pipefail

gdb $VMLINUX \
  -ex "target remote :1234" \
  -ex "lx-symbols" \
  -ex "b start_kernel"
