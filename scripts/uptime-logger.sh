#!/usr/bin/env bash
# An improved version of the uptime logger from my systemd timer lab.
set -euo pipefail

log_file="${1:-/var/log/uptime.log}"
{
  printf 'Uptime Log: %s\n' "$(date)"
  uptime
  printf '%s\n' '----------------------------------------'
} >> "$log_file"
