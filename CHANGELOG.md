# Changelog — jadlis-obsidian

Формат: [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/), версии — [SemVer](https://semver.org/lang/ru/).

## [1.0.0] — 2026-09-10 — первый выпуск / first release

### Для человека
- Второй шаг маршрута Jadlis: `/obsidian` ставит Obsidian один в один с владельцем —
  приложение, папки хранилища, конфигурация `.obsidian`, бандл скиллов и `CLAUDE.md` внутри vault.
- Приезжают 12 community-плагинов готовыми сборками, тема Border с сохранёнными цветами,
  CSS-сниппет `hide-files` и хоткеи владельца (⌘⇧H для выделения).
- Девять шагов, по одному за реплику: проверка, что купить, приложение, папки и `CLAUDE.md`,
  конфигурация, открытие хранилища и снятие Restricted mode, Sync, бандл и CLI, проверка делом.
- Платное здесь одно — подписка Obsidian Sync, покупает её человек сам по ссылке.
- Ничего не перезаписывается молча: существующие `CLAUDE.md`, `.claude/settings.json`
  и `.obsidian` требуют «да», прежняя конфигурация уходит в датированный бэкап.
- `workspace.json` получателя не трогается: вкладки и раскладка панелей остаются его.

### For agents
- Added: `.claude-plugin/plugin.json` — `jadlis-obsidian` 1.0.0, `userConfig.VAULT_PATH`
  (type `directory`, default `~/Jadlis`, не required).
- Added: `skills/obsidian/SKILL.md` (`name: obsidian` → `/obsidian`, полная форма
  `/jadlis-obsidian:obsidian`) + `references/probe-keys.md`, `references/plugins.md`.
- Added: `scripts/` — `common.sh` (общий хелпер, `$VAULT`, обёртка `obs`), `probe.sh`
  (`ключ=PASS|FAIL|SKIP`), `skeleton.sh`, `obsidian-config.sh` (сухой прогон → `OVERWRITE=1`),
  `open-vault.sh` (IPC `vault-open`), `verify-obsidian.sh`, `smoke-note.sh`.
- Added: `assets/obsidian/` — 12 плагинов (`manifest.json`, `main.js`, `styles.css`),
  тема Border, `app.json` с пустым `userIgnoreFilters`, `appearance.json`,
  `core-plugins.json` (`publish` выключен, `sync` оставлен), `hotkeys.json` без ключей
  `mindvas:*`, `snippets/hide-files.css`.
- Added: `assets/vault/` — `CLAUDE.md`, `.claude/rules/vault-cli.md`,
  `.claude/settings.json` (`plansDirectory: Система/Планы`).
- Added: `tools/export-obsidian.py` — воспроизводимая пересборка `assets/obsidian`
  из живого `.obsidian`; аудит падает с кодом 1 на личном пути, почте вне баннера
  сторонней библиотеки, `siteId` или стоп-слове.
- Note: `data.json` едет у 9 плагинов; у `periodic-notes`, `daily-note-calendar`, `my-svgs`
  и `iconic` из него сняты ключи с путями, у `flexplorer` и `sidebar-highlights` не едет вовсе.
- Note: `daily-notes.json` и `templates.json` не экспортированы — их папки лежат вне скелета
  из четырёх директорий.
- Added: `.github/workflows/ci.yml` — вызов `beCyborg/jadlis-hub/.github/workflows/plugin-ci.yml@main`,
  mode `plugin`, `forbid-mermaid: true`.
