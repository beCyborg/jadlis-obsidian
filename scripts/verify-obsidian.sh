#!/bin/sh
# Turn Restricted mode off, then check the result through the running Obsidian:
# 12 community plugins enabled, theme Border, no startup errors, the shipped hotkey bound.
# Needs a running Obsidian with $VAULT open.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

HOTKEY_ID="${HOTKEY_ID:-sidebar-highlights:create-highlight}"

obsidian_running || { say "Obsidian не запущен — сначала scripts/open-vault.sh"; exit 1; }

say "restricted mode: $(obs plugins:restrict off 2>&1 | tr -d '\r')"

enabled=$(obs plugins:enabled filter=community 2>/dev/null | tr -d '\r')
cnt=$(printf '%s\n' "$enabled" | grep -c . || true)
say "включено community-плагинов: $cnt"
printf '%s\n' "$enabled" | sed 's/^/  /'

want=$(sed -n 's/.*"\(.*\)".*/\1/p' "$ASSETS/obsidian/community-plugins.json")
for id in $want; do
  printf '%s\n' "$enabled" | grep -qi -- "$id" || say "  ОТСУТСТВУЕТ: $id"
done

say "тема: $(obs theme 2>&1 | tr -d '\r' | head -3 | tr '\n' ' ')"
say "хоткей $HOTKEY_ID: $(obs hotkeys verbose all 2>/dev/null | grep -i "$HOTKEY_ID" || echo 'не найден')"
say "ошибки: $(obs dev:errors 2>&1 | tr -d '\r' | head -5 | tr '\n' ' ')"
