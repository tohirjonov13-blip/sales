#!/usr/bin/env bash
# Keep-awake для долгих задач: не давать машине заснуть и не обрывать процесс.
#   macOS  -> настоящий caffeinate (не спать системе/диску/дисплею).
#   Linux  -> облачный раннер не засыпает, просто запускаем команду как есть.
#
# Использование:
#   .claude/hooks/keep-awake.sh <команда> [аргументы...]
# Пример:
#   .claude/hooks/keep-awake.sh npm run build:all
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: keep-awake.sh <command> [args...]" >&2
  exit 2
fi

if command -v caffeinate >/dev/null 2>&1; then
  # -d дисплей, -i idle-sleep, -m диск, -s система, -u пометить как активность.
  exec caffeinate -dimsu "$@"
else
  exec "$@"
fi
