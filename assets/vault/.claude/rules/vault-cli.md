# Obsidian CLI и поиск по vault

Vault обслуживает плагин Obsidian Skills: `obsidian-cli` (чтение, создание, поиск,
дневные заметки, properties, backlinks), `obsidian-markdown` (`.md` — всегда
Obsidian-flavored, не обычный markdown), `obsidian-bases` (`.base`),
`json-canvas` (`.canvas`).

- Бинарь называется `obsidian-cli`; симлинк `~/bin/obsidian` — 20 мс против 218 мс
  у лаунчера `Obsidian`, на который иначе разрешается PATH.
- Включён core-плагин Daily notes → `obsidian daily:path` отдаёт путь дневной заметки
  ещё до того, как файл создан; команды `daily:*` работают только при включённом плагине.
- Правки к скиллу `obsidian-cli` из поставки плагина: флага `silent` нет
  (у `create` есть opt-in `open`); `--copy` работает; есть `search:context`,
  `base:query` (детерминированный, в отличие от `search`), `unresolved`,
  `prepend` (вставляет после frontmatter); `obsidian create --help` справки не печатает —
  он создаёт `Untitled.md`.

## Ловушки поиска

Оба поисковых инструмента по умолчанию дают **тихое ложное «ничего не найдено»** —
никогда не делай вывод об отсутствии заметки по одной проверке.

1. **Grep-обёртка и `grep` в Bash содержимого vault не видят**, если папка не в git
   (Obsidian Sync, iCloud): обёртка уважает `.gitignore`. Для поиска по контенту —
   `command grep -rI "запрос" .` или `ugrep --no-ignore-files`.
2. **`obsidian search` нестабилен (race condition)**: один и тот же запрос подряд
   отдаёт `0 / 148 / 0 / 148`; `sleep` не помогает. Запускай 2–3 раза, бери непустой
   (максимальный) результат; для проверки существования используй детерминированные
   `obsidian read path="..."` / `obsidian files`.
3. **Дедуп перед записью** опирается на тот же нестабильный `obsidian search` —
   повтори ≥2 раза, прежде чем считать заметку новой.
