#!/usr/bin/env bash
# Small connectivity check adapted from my shell exercises.
# This verifies IP reachability, not DNS or full internet access.
set -euo pipefail

if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
  echo 'Host can reach 1.1.1.1.'
else
  echo 'No ICMP reply from 1.1.1.1.'
  exit 1
fi
