#!/bin/sh
# Folder skeleton + vault CLAUDE.md + .claude/{rules,settings.json}.
# Idempotent: an existing file is never overwritten — it is reported as DIFFERS,
# and the copy waits in <file>.jadlis-new for the human to decide.
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

mkdir -p "$VAULT/Входящие" "$VAULT/Файлы" "$VAULT/Знания" "$VAULT/Система/Планы"
mkdir -p "$VAULT/.claude/rules"
say "скелет: Входящие, Файлы, Знания, Система/Планы"

place() { # place <src> <dst>
  src="$1"; dst="$2"
  if [ ! -e "$dst" ]; then
    cp "$src" "$dst"
    say "NEW      ${dst#"$VAULT"/}"
  elif cmp -s "$src" "$dst"; then
    say "SAME     ${dst#"$VAULT"/}"
  else
    cp "$src" "$dst.jadlis-new"
    say "DIFFERS  ${dst#"$VAULT"/} — новая версия рядом: ${dst#"$VAULT"/}.jadlis-new"
  fi
}

place "$ASSETS/vault/CLAUDE.md" "$VAULT/CLAUDE.md"
place "$ASSETS/vault/.claude/rules/vault-cli.md" "$VAULT/.claude/rules/vault-cli.md"
place "$ASSETS/vault/.claude/settings.json" "$VAULT/.claude/settings.json"
