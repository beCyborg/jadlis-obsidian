#!/bin/sh
# Read-only probe. One `key=PASS|FAIL|SKIP` per line, plus `vault=<path>` and a
# `note:` line where the value alone would be ambiguous. SKIP = cannot be told
# right now (Obsidian is not running), not a failure.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

r() { printf '%s=%s\n' "$1" "$2"; }
n() { printf 'note: %s\n' "$*"; }

printf 'vault=%s\n' "$VAULT"

[ -d "$OBSIDIAN_APP" ] && r obsidian_app PASS || { r obsidian_app FAIL; n "нет $OBSIDIAN_APP — brew install --cask obsidian"; }
[ -x "$CLI_BIN" ] && r obsidian_cli PASS || r obsidian_cli FAIL
[ -x "$HOME/bin/obsidian" ] && r cli_symlink PASS || { r cli_symlink FAIL; n "нет ~/bin/obsidian"; }
obsidian_running && r obsidian_running PASS || { r obsidian_running SKIP; n "Obsidian не запущен — проверки через CLI пропущены"; }

[ -d "$VAULT" ] && r vault_dir PASS || r vault_dir FAIL

missing=""
for d in Входящие Файлы Знания Система/Планы; do
  [ -d "$VAULT/$d" ] || missing="$missing $d"
done
[ -z "$missing" ] && r skeleton PASS || { r skeleton FAIL; n "нет папок:$missing"; }

[ -f "$VAULT/CLAUDE.md" ] && r vault_claude_md PASS || r vault_claude_md FAIL
[ -f "$VAULT/.claude/rules/vault-cli.md" ] && r vault_rules PASS || r vault_rules FAIL
[ -f "$VAULT/.claude/settings.json" ] && r vault_settings PASS || r vault_settings FAIL

# community-plugins.json must match the shipped list exactly (order-insensitive)
if [ -f "$VAULT/.obsidian/community-plugins.json" ] && command -v jq >/dev/null 2>&1; then
  have=$(jq -S 'sort' "$VAULT/.obsidian/community-plugins.json" 2>/dev/null)
  want=$(jq -S 'sort' "$ASSETS/obsidian/community-plugins.json" 2>/dev/null)
  if [ "$have" = "$want" ]; then
    r plugins_list PASS
  else
    r plugins_list FAIL
    n "список плагинов в vault не совпадает с поставкой"
  fi
else
  r plugins_list FAIL
  n "нет $VAULT/.obsidian/community-plugins.json (или нет jq)"
fi

if [ -f "$VAULT/.obsidian/appearance.json" ] && grep -q '"cssTheme": *"Border"' "$VAULT/.obsidian/appearance.json" 2>/dev/null; then
  r theme_border PASS
else
  r theme_border FAIL
fi

if obsidian_running; then
  state=$(obs plugins:restrict 2>/dev/null || true)
  case "$state" in
    *off*|*Off*|*disabled*|*Disabled*) r restricted_mode PASS ;;
    "") r restricted_mode SKIP; n "obsidian-cli не ответил — vault ещё не открыт в Obsidian?" ;;
    *) r restricted_mode FAIL; n "Restricted mode: $state" ;;
  esac
  enabled=$(obs plugins:enabled filter=community 2>/dev/null | tr -d '\r' || true)
  cnt=$(printf '%s' "$enabled" | grep -c . || true)
  if [ "${cnt:-0}" -ge 12 ]; then r plugins_enabled PASS; else r plugins_enabled FAIL; fi
  n "включено community-плагинов: ${cnt:-0} из 12"
else
  r restricted_mode SKIP
  r plugins_enabled SKIP
fi

if claude plugin list 2>/dev/null | grep -q 'obsidian@obsidian-skills'; then
  r skills_bundle PASS
else
  r skills_bundle FAIL
  n "не установлен obsidian@obsidian-skills"
fi
