#!/usr/bin/env bash
set -euo pipefail
cd /hive/miners/custom/meowminer 2>/dev/null || cd "$(dirname "${BASH_SOURCE:-$0}")" 2>/dev/null || true
flight_algo="${CUSTOM_ALGO:-}"
. ./h-manifest.conf
[ -z "$flight_algo" ] || export CUSTOM_ALGO="$flight_algo"

if [ -n "${CUSTOM_TEMPLATE:-}" ] || [ ! -f "$CUSTOM_CONFIG_FILENAME" ]; then
  ./h-config.sh
fi
set -a
. "$CUSTOM_CONFIG_FILENAME"
set +a

mkdir -p "$(dirname "$CUSTOM_LOG_BASENAME")"
chmod +x ./MeowMiner ./start.sh ./btx/*.sh ./btx/bin/* ./pearl/MeowMiner-pearl* ./pearl/pearl_ours 2>/dev/null || true
exec ./MeowMiner 2>&1 | tee -a "$CUSTOM_LOG_BASENAME.log"
