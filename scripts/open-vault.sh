#!/bin/sh
# Register and open $VAULT in Obsidian.
# Obsidian is already running -> ask the running app over IPC, no clicking needed.
# Obsidian is not running     -> start it; the human picks "Open folder as vault".
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

[ -d "$VAULT" ] || { say "нет папки vault: $VAULT"; exit 1; }

if obsidian_running; then
  out=$("$CLI_BIN" eval "code=window.electron.ipcRenderer.sendSync('vault-open', '$VAULT', false)" 2>&1 || true)
  say "vault-open -> $out"
  case "$out" in
    *true*) say "OK: $VAULT_NAME открыт в Obsidian" ;;
    *) say "IPC не подтвердил открытие — открой руками: Obsidian -> Open folder as vault -> $VAULT" ;;
  esac
else
  open -a Obsidian
  say "Obsidian запущен."
  say "Дальше руками: Open folder as vault -> $VAULT"
fi
