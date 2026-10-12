#!/usr/bin/env bash
# Corrected version of my Bash disk usage conditional exercise.
set -euo pipefail

mountpoint="${1:-/}"
usage=$(df -P "$mountpoint" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
  echo 'Could not determine disk usage.' >&2
  exit 2
fi

if (( usage < 50 )); then
  echo 'Disk usage is under control.'
elif (( usage < 80 )); then
  echo 'Disk usage is moderate.'
else
  echo 'Disk usage is critical!'
fi
