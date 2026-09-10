#!/bin/sh
# Final check: Claude writes a note into Входящие/ through obsidian-cli and reads it back.
# Needs a running Obsidian with $VAULT open.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

NAME="${NAME:-Проверка связки $(date +%H-%M-%S)}"

obsidian_running || { say "Obsidian не запущен — сначала scripts/open-vault.sh"; exit 1; }

obs create "path=Входящие/$NAME.md" \
  "content=Эту заметку создал Claude Code через obsidian-cli.\n\nЕсли ты её видишь в Obsidian — связка работает." \
  >/dev/null 2>&1 || { say "create не прошёл"; exit 1; }

say "создана: Входящие/$NAME.md"
say "--- чтение обратно ---"
obs read "path=Входящие/$NAME.md" 2>&1 | sed 's/^/  /'
