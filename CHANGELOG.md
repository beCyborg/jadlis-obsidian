# Changelog — jadlis-obsidian

Формат: [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/), версии — [SemVer](https://semver.org/lang/ru/).

## [1.0.1] — 2026-09-30 — Без Linter и Periodic Notes / Linter and Periodic Notes dropped

### Для человека
- В сборке теперь 10 community-плагинов: владелец убрал из своего vault Linter и Periodic Notes.
- Linter только проставлял даты `created`/`modified`, которые никто не читает. Periodic Notes 0.0.17
  заброшен, помечен уязвимыми зависимостями и дублирует календарь Daily notes calendar и скиллы
  заметок дня.

### For agents
- Removed: `assets/obsidian/plugins/obsidian-linter/`, `assets/obsidian/plugins/periodic-notes/`
  and both ids in `assets/obsidian/community-plugins.json` (12 → 10).
- Removed: their `DATA_JSON_POLICY` entries in `tools/export-obsidian.py` (incl. the periodic-notes
  `*.folder`/`*.template` strip rule).
- Changed: plugin count 12 → 10 and plugin lists in `.claude-plugin/plugin.json`, `README.md`,
  `README.en.md`, `skills/obsidian/SKILL.md`, `skills/obsidian/references/plugins.md`,
  `skills/obsidian/references/probe-keys.md`, `scripts/probe.sh` (`plugins_enabled` threshold
  `-ge 10`), `scripts/verify-obsidian.sh` (header comment).
- Migration: a recipient who already installed 1.0.0 keeps both plugins; nothing in the bundle
  depends on them, remove them from Community plugins by hand if unwanted.

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
