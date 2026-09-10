---
name: obsidian
description: "Второй шаг маршрута Jadlis: ставит Obsidian один в один с владельцем — приложение, подписка Sync, папки vault, конфигурация .obsidian (12 плагинов, тема Border, хоткеи), скиллы Obsidian для Claude Code и CLAUDE.md внутри vault.\nTRIGGER when: user says \"/obsidian\", \"настрой obsidian\", \"поставь obsidian\", \"obsidian как у тебя\", \"перенеси настройки obsidian\", \"второй шаг\", \"шаг 2 маршрута\", \"setup obsidian\", \"obsidian статус\", \"проверь obsidian\".\nDO NOT TRIGGER when: настройка самого Claude Code (~/.claude, модели, права) — это первый шаг маршрута; голос и диктовка — /jadlis-voice; работа с заметками в уже настроенном vault — скиллы obsidian-cli / obsidian-markdown из бандла."
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
argument-hint: "[статус | ставить | заново]"
---

# Obsidian один в один

`$ARGUMENTS`

```
VAULT   = ${user_config.VAULT_PATH}
SCRIPTS = ${CLAUDE_PLUGIN_ROOT}/scripts
ASSETS  = ${CLAUDE_PLUGIN_ROOT}/assets
```

Читателю с СДВГ: **первая строка — действие**, один шаг за реплику, в списке не больше пяти
пунктов. Не вываливай все девять шагов сразу — веди по одному и говори, какой сейчас из девяти.

Правило на весь скилл: **сначала объясни одной строкой, что и зачем, потом делай**.
Файл уже есть — **спроси перед перезаписью**, молча не затирай.

Все шаги гоняй с `VAULT`, а не с `~/Jadlis`:

```bash
export VAULT="${user_config.VAULT_PATH:-$HOME/Jadlis}"
```

## Шаг 1 из 9 — что уже есть

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/probe.sh"
```

Вывод — строки `ключ=PASS|FAIL|SKIP`. `SKIP` значит «сейчас не проверить»
(Obsidian не запущен), а не «сломано». Расшифровка ключей — `references/probe-keys.md`.

Всё `PASS` — скажи одной строкой «Obsidian уже как у владельца» и переходи к шагу 9
(проверка). Иначе назови **только те ключи, что FAIL**, и иди дальше.

## Шаг 2 из 9 — что купить

Одна платная вещь во всём этом шаге — **Obsidian Sync**: <https://obsidian.md/sync>.
Цена — на странице, покупает человек сам.

Зачем: заметки появляются на телефоне и живут в бэкапе с историей версий.
Само приложение бесплатное; больше в этом плагине не платится ничего.

Скажи это двумя строками и **не жди оплаты** — остальные шаги от Sync не зависят.

## Шаг 3 из 9 — приложение

`obsidian_app=FAIL` → поставить:

```bash
brew install --cask obsidian
```

Нет Homebrew — дай ссылку <https://obsidian.md> и скажи, что дальше пойдём, когда
приложение окажется в `/Applications`.

## Шаг 4 из 9 — папки и CLAUDE.md

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/skeleton.sh"
```

Создаёт `Входящие`, `Файлы`, `Знания`, `Система/Планы` и кладёт `CLAUDE.md`,
`.claude/rules/vault-cli.md`, `.claude/settings.json`.

Скрипт печатает `NEW` / `SAME` / `DIFFERS`. **`DIFFERS` — остановись**: покажи `diff`
между файлом и `<файл>.jadlis-new` и спроси, что оставить. Решает человек.

```bash
diff -u "$VAULT/CLAUDE.md" "$VAULT/CLAUDE.md.jadlis-new" | head -40
```

## Шаг 5 из 9 — конфигурация `.obsidian`

Сначала сухой прогон — он ничего не меняет и показывает список файлов:

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/obsidian-config.sh"
```

Выход `2` и список `NEW/REPLACE/SAME` — покажи из него **до пяти строк** и спроси
одним вопросом: «Кладу конфигурацию владельца? `workspace.json` (твои вкладки и панели)
не трогается, прежняя копия уходит в бэкап рядом». Ответили «да»:

```bash
OVERWRITE=1 sh "${CLAUDE_PLUGIN_ROOT}/scripts/obsidian-config.sh"
```

Что кладётся: 12 community-плагинов, тема Border, CSS-сниппет `hide-files`, хоткеи,
`app.json`, `appearance.json`, `core-plugins.json`. Что не кладётся: `workspace*.json`,
закладки, граф, данные Sync и Publish. Таблица плагинов — `references/plugins.md`.

**Obsidian с этим vault должен быть закрыт**: открытое приложение перезаписывает
`.obsidian/` своим состоянием.

## Шаг 6 из 9 — открыть vault и снять Restricted mode

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/open-vault.sh"
```

Obsidian уже запущен — папка регистрируется через IPC, кликать не надо.
Не запущен — скрипт его стартует, а человек выбирает **Open folder as vault** → `$VAULT`.

Дальше проверка (она же выключает Restricted mode — без этого community-плагины молчат):

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/verify-obsidian.sh"
```

Жди в выводе: 12 включённых плагинов, тема `Border`, пустые ошибки, строку про хоткей.
Чего-то нет — назови ровно это, не пересказывай весь вывод.

Хоткей проверяется **действием**, а не наличием файла. Попроси человека открыть любую
заметку, выделить слово и нажать **⌘⇧H** — текст должен подсветиться. Не сработало —
Settings → Hotkeys → найти `Sidebar Highlights: Create highlight`.

## Шаг 7 из 9 — включить Sync

Только руками, из интерфейса: **Settings → Sync → войти в аккаунт → Connect**.
CLI сюда не лезет и не должен.

Купил Sync на шаге 2 — заведи здесь. Не купил — пропусти, ничего не сломается,
заметки просто останутся на одной машине.

## Шаг 8 из 9 — бандл скиллов и CLI

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/bundle.sh"
```

Ставит `obsidian@obsidian-skills` (скиллы `obsidian-cli`, `obsidian-markdown`,
`obsidian-bases`, `json-canvas`) и делает симлинк `~/bin/obsidian` на бинарь CLI
внутри приложения. Скрипт скажет, если `~/bin` нет в `PATH` — тогда дай ровно одну
строку для `~/.zshrc`.

## Шаг 9 из 9 — проверка

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/smoke-note.sh"
```

Claude создаёт заметку в `Входящие/` через `obsidian-cli` и читает её обратно.
Прочиталась — связка «Claude Code ↔ Obsidian» рабочая.

Закончи ровно двумя строками:

1. Что теперь работает: «Obsidian как у владельца, Claude пишет и читает заметки в `$VAULT`».
2. Дальше: `/jadlis-voice` — третий шаг маршрута.

## Чего не делать

- Не перезаписывать `CLAUDE.md`, `.claude/settings.json` и `.obsidian/` без «да».
- Не удалять `workspace.json` получателя — там его вкладки и панели.
- Не править `.obsidian/` при открытом Obsidian: приложение затрёт правки.
- Не ставить и не настраивать ничего платного, кроме Sync, и не оформлять подписку за человека.
- Не тащить сюда семантический поиск по заметкам — в этой поставке его нет.
