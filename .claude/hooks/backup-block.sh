#!/usr/bin/env bash
# Backup перед глобальными изменениями архитектуры / логики / дизайна.
# Сохраняет ПОЛНУЮ копию файла в .claude/backups/<timestamp>-<метка>/ с сохранением
# относительного пути, прежде чем ты начнёшь переписывать блок.
#
# Использование:
#   .claude/hooks/backup-block.sh <путь-к-файлу> [метка]
# Пример:
#   .claude/hooks/backup-block.sh index.html redesign-header
set -euo pipefail

file="${1:-}"
label="${2:-change}"

if [ -z "$file" ] || [ ! -f "$file" ]; then
  echo "usage: backup-block.sh <existing-file> [label]" >&2
  exit 2
fi

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ts="$(date +%Y%m%d-%H%M%S)"
# Имя метки без пробелов/слешей, чтобы не плодить мусорные пути.
safe_label="$(printf '%s' "$label" | tr ' /' '__')"
dest_dir="$root/.claude/backups/$ts-$safe_label"

# Относительный путь файла внутри проекта (если файл внутри root).
abs_file="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
rel="${abs_file#"$root"/}"

mkdir -p "$dest_dir/$(dirname "$rel")"
cp -p "$abs_file" "$dest_dir/$rel"
echo "backup -> $dest_dir/$rel"
