#!/usr/bin/env bash
set -euo pipefail
cd /hive/miners/custom/meowminer 2>/dev/null || cd "$(dirname "${BASH_SOURCE:-$0}")" 2>/dev/null || true
flight_algo="${CUSTOM_ALGO:-}"
. ./h-manifest.conf

coin="${MEOW_COIN:-$flight_algo}"
coin="$(printf '%s' "$coin" | tr '[:upper:]' '[:lower:]')"
case "$coin" in
  btx|matmul) coin=btx ;;
  pearl|pearlhash) coin=pearl ;;
  *)
    case "${CUSTOM_TEMPLATE:-${CUSTOM_WALLET:-}}" in
      btx1*) coin=btx ;;
      *) coin=pearl ;;
    esac
    ;;
esac

pool="${CUSTOM_URL:-}"
if [ -z "$pool" ]; then
  if [ "$coin" = btx ]; then pool="btx-us-east.lproute.com:8660"; else pool="us2.pearl.herominers.com:1200"; fi
fi

{
  printf 'MEOW_COIN=%q\n' "$coin"
  printf 'MEOW_USER=%q\n' "${CUSTOM_TEMPLATE:-${CUSTOM_WALLET:-}}"
  printf 'MEOW_POOL=%q\n' "$pool"
  printf 'MEOW_WORKER=%q\n' "${WORKER_NAME:-$(hostname)}"
  printf 'MEOW_PASSWORD=%q\n' "${CUSTOM_PASS:-x}"
  [ -z "${CUSTOM_DEVICES:-}" ] || printf 'MEOW_DEVICES=%q\n' "$CUSTOM_DEVICES"
  [ -z "${CUSTOM_USER_CONFIG:-}" ] || printf '%s\n' "$CUSTOM_USER_CONFIG"
} > "$CUSTOM_CONFIG_FILENAME"

echo "MeowMiner $coin config written to $CUSTOM_CONFIG_FILENAME"
