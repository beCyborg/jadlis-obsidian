#!/bin/sh
# Shared helpers for the jadlis-obsidian scripts. Sourced, never run directly.
# Honours $VAULT (falls back to ~/Jadlis) and $CLAUDE_PLUGIN_ROOT.

ROOT="${CLAUDE_PLUGIN_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
ASSETS="$ROOT/assets"

VAULT="${VAULT:-$HOME/Jadlis}"
case "$VAULT" in
  "~") VAULT="$HOME" ;;
  "~/"*) VAULT="$HOME/${VAULT#\~/}" ;;
esac
VAULT_NAME=$(basename "$VAULT")

OBSIDIAN_APP="/Applications/Obsidian.app"
CLI_BIN="$OBSIDIAN_APP/Contents/MacOS/obsidian-cli"

# obs <args...> — run obsidian-cli against $VAULT_NAME; needs a running Obsidian.
obs() {
  if [ -x "$HOME/bin/obsidian" ]; then
    "$HOME/bin/obsidian" "vault=$VAULT_NAME" "$@"
  elif [ -x "$CLI_BIN" ]; then
    "$CLI_BIN" "vault=$VAULT_NAME" "$@"
  else
    return 127
  fi
}

obsidian_running() {
  pgrep -x Obsidian >/dev/null 2>&1
}

say() { printf '%s\n' "$*"; }
