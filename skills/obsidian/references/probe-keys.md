# Ключи `scripts/probe.sh`

`PASS` — в порядке, `FAIL` — надо чинить, `SKIP` — сейчас не проверить
(Obsidian не запущен, CLI не отвечает). `SKIP` не считается ошибкой.

| Ключ | Что проверяет | Чинится на шаге |
|---|---|---|
| `obsidian_app` | `/Applications/Obsidian.app` на месте | 3 |
| `obsidian_cli` | бинарь `obsidian-cli` внутри приложения | 3 |
| `cli_symlink` | симлинк `~/bin/obsidian` | 8 |
| `obsidian_running` | приложение запущено (нужно для CLI-проверок) | 6 |
| `vault_dir` | папка `$VAULT` существует | 4 |
| `skeleton` | есть `Входящие`, `Файлы`, `Знания`, `Система/Планы` | 4 |
| `vault_claude_md` | `$VAULT/CLAUDE.md` | 4 |
| `vault_rules` | `$VAULT/.claude/rules/vault-cli.md` | 4 |
| `vault_settings` | `$VAULT/.claude/settings.json` (`plansDirectory`) | 4 |
| `plugins_list` | `community-plugins.json` совпадает с поставкой | 5 |
| `theme_border` | `appearance.json` → `cssTheme: Border` | 5 |
| `restricted_mode` | Restricted mode выключен | 6 |
| `plugins_enabled` | Obsidian отдаёт ≥12 включённых community-плагинов | 6 |
| `skills_bundle` | установлен `obsidian@obsidian-skills` | 8 |

Первая строка вывода — `vault=<путь>`: с ней видно, куда скрипт целится.
Строки `note: …` поясняют неочевидный `FAIL` (какой папки нет, сколько плагинов включено).

`plugins_list` требует `jq`. Нет `jq` — ключ уходит в `FAIL` со строкой `note:`;
поставить: `brew install jq`.
