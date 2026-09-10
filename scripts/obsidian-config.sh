#!/bin/sh
# Put the shipped .obsidian/ configuration into $VAULT.
#
#   sh scripts/obsidian-config.sh            # dry run: says what it would change
#   OVERWRITE=1 sh scripts/obsidian-config.sh
#
# workspace.json, workspace-mobile.json and everything not part of the bundle are left
# alone: the recipient's open tabs and pane layout are not ours to replace. An existing
# file that we do replace is backed up next to the vault first.
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

SRC="$ASSETS/obsidian"
DST="$VAULT/.obsidian"
OVERWRITE="${OVERWRITE:-0}"

[ -d "$VAULT" ] || { say "нет папки vault: $VAULT"; exit 1; }
[ -d "$SRC" ] || { say "нет $SRC — сначала tools/export-obsidian.py"; exit 1; }

if [ "$OVERWRITE" != "1" ] && [ -d "$DST" ]; then
  say "в $DST уже есть конфигурация — что будет заменено:"
  (cd "$SRC" && find . -type f) | sed 's|^\./||' | while read -r rel; do
    if [ -e "$DST/$rel" ]; then
      cmp -s "$SRC/$rel" "$DST/$rel" && say "  SAME     $rel" || say "  REPLACE  $rel"
    else
      say "  NEW      $rel"
    fi
  done | sort -u | head -40
  say ""
  say "workspace.json и всё остальное не трогается."
  say "Согласен — повтори с OVERWRITE=1."
  exit 2
fi

if [ -d "$DST" ]; then
  BACKUP="$VAULT/.obsidian.jadlis-backup-$(date +%Y%m%d-%H%M%S)"
  cp -R "$DST" "$BACKUP"
  say "бэкап прежней конфигурации: ${BACKUP#"$VAULT"/}"
fi

mkdir -p "$DST"
(cd "$SRC" && find . -type f) | sed 's|^\./||' | while read -r rel; do
  mkdir -p "$DST/$(dirname "$rel")"
  cp "$SRC/$rel" "$DST/$rel"
done

say "конфигурация разложена в ${DST#"$VAULT"/}"
say "плагинов: $(ls -1 "$DST/plugins" | wc -l | tr -d ' '), тема: $(ls -1 "$DST/themes" | tr -d ' ')"
