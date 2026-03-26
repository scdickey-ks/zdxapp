#!/usr/bin/env bash
# Copy to smoke_curl.sh, fill ZDX_PILOT_URL from docs, run locally. Do not commit smoke_curl.sh.
set -euo pipefail
: "${ZDX_KEY_ID:?set ZDX_KEY_ID}"
: "${ZDX_KEY_SECRET:?set ZDX_KEY_SECRET}"
# ZDX_PILOT_URL="https://..."   # from Zscaler ZDX API documentation

curl -sS -u "${ZDX_KEY_ID}:${ZDX_KEY_SECRET}" \
  -H "Accept: application/json" \
  "${ZDX_PILOT_URL}" | head -c 4000

echo
