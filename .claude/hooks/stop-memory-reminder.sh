#!/usr/bin/env bash
# Stop-hook: после завершения задачи напоминает обновить память проекта (CLAUDE.md).
# Срабатывает ровно один раз за остановку — защита от бесконечного цикла через
# поле stop_hook_active во входном JSON.
set -euo pipefail

input="$(cat)"

# Если хук уже сработал в этом цикле остановки — разрешаем остановиться, не зацикливаемся.
if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# Нет git — тихо выходим (нечем измерить «была ли работа»).
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Нет изменений в рабочем дереве — значит, ничего не меняли, напоминание не нужно.
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

# CLAUDE.md уже затронут — память, вероятно, обновлена, не дёргаем.
if git status --porcelain 2>/dev/null | grep -qE 'CLAUDE\.md$'; then
  exit 0
fi

# Была работа, но память не тронута — одно напоминание.
cat <<'JSON'
{"decision":"block","reason":"Задача завершена, но CLAUDE.md/память проекта не обновлены. Кратко зафиксируй в CLAUDE.md: что изменилось (архитектура/логика/дизайн), ключевые решения и контекст для будущих сессий. Если обновлять нечего — явно подтверди это и заверши."}
JSON
exit 0
