#!/usr/bin/env bash
cd /hive/miners/custom/meowminer 2>/dev/null || cd "$(dirname "${BASH_SOURCE:-$0}")" 2>/dev/null || true
. ./h-manifest.conf
[ -f "$CUSTOM_CONFIG_FILENAME" ] && . "$CUSTOM_CONFIG_FILENAME"

case "${MEOW_COIN:-pearl}" in
  btx)
    export BTX_HIVE_MINER_DIR="$PWD/btx"
    export BTX_HIVE_LOG_DIR="$PWD/btx/logs"
    . "$PWD/btx/h-stats.sh"
    ;;
  *)
    old_pwd="$PWD"
    cd "$PWD/pearl" || { khs=0; stats=null; return 0 2>/dev/null || exit 0; }
    . ./h-stats.sh
    cd "$old_pwd" || true
    ;;
esac
true
