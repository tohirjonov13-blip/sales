# Unified workflow package (`.claude/`)

Единый переносимый пакет с предпочтениями: положи папку `.claude/` в корень любого
проекта — и поведение применится в Claude Code автоматически.

## Что внутри

```
.claude/
├── settings.json                     # авто-апрув команд (кроме удаления) + Stop-hook
├── skills/
│   └── workflow-orchestrator/
│       └── SKILL.md                  # описание всего рабочего процесса
└── hooks/
    ├── stop-memory-reminder.sh       # напоминание обновить CLAUDE.md после задачи
    ├── keep-awake.sh                 # caffeinate-обёртка для долгих задач
    └── backup-block.sh               # backup файла перед глобальными изменениями
```

## Установка в новый проект

```bash
# из корня целевого проекта:
cp -r /путь/к/sales/.claude .
chmod +x .claude/hooks/*.sh
```

Хуки и `settings.json` подхватятся при следующем запуске Claude Code в этом проекте.
Скилл `workflow-orchestrator` станет доступен автоматически.

> Рекомендуется добавить `CLAUDE.md` в корень проекта (см. шаблон ниже в этом репо)
> — он загружается в каждой сессии и держит правила всегда активными.

## Поведения

| Поведение                       | Механизм                                  |
|---------------------------------|-------------------------------------------|
| Авто-апрув команд               | `settings.json` → `permissions.allow`     |
| Запрос при удалении файлов      | `settings.json` → `permissions.ask`       |
| Обновление памяти после задачи  | `hooks/stop-memory-reminder.sh` (Stop)    |
| Keep-awake для долгих задач     | `hooks/keep-awake.sh`                      |
| Backup перед крупными правками  | `hooks/backup-block.sh`                    |
| superpowers                     | плагин (см. ниже)                          |

## superpowers

`superpowers` — это коллекция скиллов, ставится как плагин Claude Code из
marketplace. В Claude Code выполни:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers
```

После установки скиллы superpowers доступны во всех проектах (плагины ставятся
глобально, не на репозиторий). Точные идентификаторы marketplace/плагина сверь
в выводе `/plugin marketplace add ...` — если имя отличается, используй то, что
показал Claude Code.

## Важно про авто-апрув (риск)

Авто-апрув включён для **всех** команд, кроме списка удаления в `permissions.ask`.
Это удобно, но deny/ask-список не пуленепробиваем: команду удаления можно «спрятать»
(например, внутри `bash -c "..."`, пайпа или скрипта), и тогда переспрос не сработает.
Удаляй файлы явными командами. При желании сузить авто-апрув — замени `"Bash"`
в `permissions.allow` на конкретные префиксы (`"Bash(git:*)"`, `"Bash(npm:*)"` и т.п.).

## Откат бэкапов

Копии лежат в `.claude/backups/<timestamp>-<метка>/`. Чтобы откатить:

```bash
cp .claude/backups/<timestamp>-<метка>/<путь-к-файлу> <путь-к-файлу>
```
