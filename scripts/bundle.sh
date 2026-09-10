#!/bin/sh
# Obsidian skills bundle for Claude Code + the obsidian-cli symlink in ~/bin.
# Idempotent: an installed marketplace/plugin and an existing symlink are left alone.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

if claude plugin list 2>/dev/null | grep -q 'obsidian@obsidian-skills'; then
  say "obsidian@obsidian-skills уже установлен"
else
  claude plugin marketplace add kepano/obsidian-skills || say "маркетплейс уже добавлен либо не добавился"
  claude plugin install obsidian@obsidian-skills || say "установка не прошла — поставь вручную"
fi

mkdir -p "$HOME/bin"
if [ -L "$HOME/bin/obsidian" ]; then
  say "симлинк уже есть: $(readlink "$HOME/bin/obsidian")"
elif [ -e "$HOME/bin/obsidian" ]; then
  say "в ~/bin/obsidian лежит не симлинк — не трогаю"
elif [ -x "$CLI_BIN" ]; then
  ln -s "$CLI_BIN" "$HOME/bin/obsidian"
  say "создан симлинк ~/bin/obsidian -> $CLI_BIN"
else
  say "нет $CLI_BIN — Obsidian не установлен"
fi

case ":$PATH:" in
  *":$HOME/bin:"*) say "~/bin уже в PATH" ;;
  *) say "добавь в ~/.zshrc:  export PATH=\"\$HOME/bin:\$PATH\"" ;;
esac
