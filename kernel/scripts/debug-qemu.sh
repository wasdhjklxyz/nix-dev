#!/usr/bin/env bash

set -euo pipefail

start-qemu $1 "nokaslr" "-s"
