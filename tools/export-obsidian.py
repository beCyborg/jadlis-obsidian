#!/usr/bin/env python3
"""Export the owner's live Obsidian configuration into assets/obsidian/ (repeatable, owner-side).

Reads a real `.obsidian/` folder and writes a sanitised copy that a recipient can drop into
an empty vault. Ships strictly what `community-plugins.json` lists; personal data, vault paths
and workspace state stay behind.

Usage:
  python3 tools/export-obsidian.py                            # ~/Jadlis/.obsidian -> assets/obsidian
  python3 tools/export-obsidian.py --source ~/Vault/.obsidian --out assets/obsidian
  python3 tools/export-obsidian.py --stop-words words.txt     # extra forbidden substrings

Exit code 1 on any privacy hit: `/Users/<name>`, an e-mail outside an upstream OSS banner,
`siteId`, or a stop word.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

# --- what leaves the owner's machine -------------------------------------------------------

PLUGIN_FILES = ("manifest.json", "main.js", "styles.css")
# Upstream license files travel with the build whenever the author ships one.
LICENSE_GLOBS = ("LICENSE*", "license*", "COPYING*", "NOTICE*")

# data.json is shipped only for these ids; everything else keeps its defaults on first run.
# Values are the keys stripped before writing (dotted paths, "*" = every item of a mapping).
DATA_JSON_POLICY: dict[str, list[str]] = {
    "obsidian-style-settings": [],          # theme knobs only, no paths — the theme needs them
    "obsidian-linter": [],                  # rule toggles, foldersToIgnore/filesToIgnore empty
    "editing-toolbar": [],                  # toolbar layout and colours, no paths
    "dragger": [],                          # drag handles UI, no paths
    "folder-notes": [],                     # behaviour flags, templatePath empty
    "periodic-notes": ["*.folder", "*.template"],
    "daily-note-calendar": ["*.folder", "*.templateFile"],
    "my-svgs": ["iconsFolder"],
    "iconic": ["fileIcons", "fileRules", "folderRules", "tabIcons", "bookmarkIcons", "tagIcons"],
}
# Not shipped at all (thousands of vault paths inside):
DATA_JSON_EXCLUDED = {"flexplorer", "sidebar-highlights"}

ROOT_JSON_KEEP = ("app.json", "appearance.json", "community-plugins.json", "core-plugins.json")
CORE_PLUGINS_DISABLE = ("publish",)          # sync stays enabled: the recipient buys Sync
HOTKEY_PREFIX_DROP = ("mindvas:",)           # that plugin is not part of this bundle
SKELETON_FOLDERS = ("Входящие", "Файлы", "Знания", "Система/Планы")

# --- privacy guard --------------------------------------------------------------------------

RX_USER_PATH = re.compile(r"/Users/[A-Za-z0-9_.-]+/")
RX_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
RX_SITEID = re.compile(r"siteId", re.I)
RX_BANNER = re.compile(r"^\s*(\*|//|/\*)|@author|@license")
PRIVACY_OK = "privacy-ok: upstream OSS author banner"
BUNDLES = {".js", ".css"}


def apply_policy(data: dict, policy: list[str]) -> None:
    """`*.key` drops `key` from every nested mapping; a bare `key` is emptied in place."""
    for spec in policy:
        if spec.startswith("*."):
            name = spec[2:]
            for value in data.values():
                if isinstance(value, dict):
                    value.pop(name, None)
        elif spec in data and isinstance(data[spec], (dict, list)):
            data[spec] = [] if isinstance(data[spec], list) else {}
        else:
            data.pop(spec, None)


def write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def export_data_json(plugin_id: str, src: Path, dst: Path, log: list[str]) -> None:
    if plugin_id in DATA_JSON_EXCLUDED or plugin_id not in DATA_JSON_POLICY:
        log.append(f"  data.json  пропущен ({plugin_id})")
        return
    if not src.exists():
        return
    data = json.loads(src.read_text(encoding="utf-8"))
    policy = DATA_JSON_POLICY[plugin_id]
    apply_policy(data, policy)
    write_json(dst, data)
    note = f" (снято: {', '.join(policy)})" if policy else ""
    log.append(f"  data.json  {plugin_id}{note}")


def copy_licenses(src_dir: Path, dst_dir: Path) -> int:
    """Carry the author's own LICENSE/NOTICE next to the build it belongs to."""
    n = 0
    for pattern in LICENSE_GLOBS:
        for f in sorted(src_dir.glob(pattern)):
            if f.is_file():
                shutil.copy2(f, dst_dir / f.name)
                n += 1
    return n


def copy_bundle(src: Path, dst: Path) -> int:
    """Copy a vendored bundle, marking upstream author banners so privacy-grep stays quiet."""
    marked = 0
    raw = src.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        dst.write_bytes(raw)
        return 0
    if RX_EMAIL.search(text):
        lines = text.split("\n")
        for i, line in enumerate(lines):
            if RX_EMAIL.search(line) and RX_BANNER.search(line) and "privacy-ok" not in line:
                lines[i] = f"{line}  ({PRIVACY_OK})"
                marked += 1
        text = "\n".join(lines)
    dst.write_text(text, encoding="utf-8")
    return marked


def audit(out: Path, stop_words: list[str]) -> int:
    """Scan the produced tree. Returns the number of unresolved hits."""
    rx_stop = re.compile("|".join(re.escape(w) for w in stop_words), re.I) if stop_words else None
    hits = 0
    for path in sorted(out.rglob("*")):
        if not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        bundle = path.suffix in BUNDLES
        for ln, line in enumerate(text.split("\n"), 1):
            if "privacy-ok" in line:
                continue
            found = []
            if RX_USER_PATH.search(line):
                found.append("личный путь")
            if RX_SITEID.search(line):
                found.append("siteId")
            if rx_stop and rx_stop.search(line):
                found.append("стоп-слово")
            if RX_EMAIL.search(line) and not (bundle and RX_BANNER.search(line)):
                found.append("почта")
            if found:
                hits += 1
                print(f"HIT  {'/'.join(found):<24} {path.relative_to(out)}:{ln}: {line.strip()[:100]}")
    return hits


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    repo = Path(__file__).resolve().parent.parent
    ap.add_argument("--source", type=Path, default=Path.home() / "Jadlis" / ".obsidian")
    ap.add_argument("--out", type=Path, default=repo / "assets" / "obsidian")
    ap.add_argument("--stop-words", type=Path, help="файл со стоп-словами, по одному на строку")
    args = ap.parse_args()

    src, out = args.source.expanduser(), args.out.expanduser()
    if not src.is_dir():
        print(f"нет папки {src}", file=sys.stderr)
        return 2
    stop_words = []
    if args.stop_words and args.stop_words.exists():
        stop_words = [w.strip() for w in args.stop_words.read_text(encoding="utf-8").splitlines()
                      if w.strip() and not w.startswith("#")]

    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    log: list[str] = []

    # 1. plugin list is the contract: everything else follows from it
    plugin_ids = json.loads((src / "community-plugins.json").read_text(encoding="utf-8"))
    write_json(out / "community-plugins.json", plugin_ids)
    log.append(f"community-plugins.json — {len(plugin_ids)} плагинов")

    marked = 0
    licenses = 0
    for plugin_id in plugin_ids:
        pdir = src / "plugins" / plugin_id
        if not pdir.is_dir():
            print(f"плагин {plugin_id} есть в списке, но папки нет: {pdir}", file=sys.stderr)
            return 2
        dest = out / "plugins" / plugin_id
        dest.mkdir(parents=True)
        for name in PLUGIN_FILES:
            f = pdir / name
            if not f.exists():
                continue
            if f.suffix in BUNDLES:
                marked += copy_bundle(f, dest / name)
            else:
                shutil.copy2(f, dest / name)
        licenses += copy_licenses(pdir, dest)
        export_data_json(plugin_id, pdir / "data.json", dest / "data.json", log)
    log.append(f"plugins/ — {len(plugin_ids)} папок, только {', '.join(PLUGIN_FILES)} (+ разрешённые data.json)")
    log.append(f"файлов лицензий от авторов плагинов: {licenses}")
    if marked:
        log.append(f"пометок privacy-ok в баннерах сторонних библиотек: {marked}")

    # 2. app.json — vault-wide behaviour; personal ignore filters replaced by the skeleton
    app = json.loads((src / "app.json").read_text(encoding="utf-8"))
    app["userIgnoreFilters"] = []
    write_json(out / "app.json", app)
    log.append("app.json — userIgnoreFilters очищен")

    # 3. appearance.json — theme and CSS snippets, as is
    shutil.copy2(src / "appearance.json", out / "appearance.json")
    log.append("appearance.json — как есть")

    # 4. core-plugins.json — Sync stays on (the recipient buys it), Publish off
    core = json.loads((src / "core-plugins.json").read_text(encoding="utf-8"))
    for key in CORE_PLUGINS_DISABLE:
        if key in core:
            core[key] = False
    write_json(out / "core-plugins.json", core)
    log.append(f"core-plugins.json — выключено: {', '.join(CORE_PLUGINS_DISABLE)}; sync оставлен")

    # 5. hotkeys.json — minus commands of plugins that are not shipped
    hotkeys = json.loads((src / "hotkeys.json").read_text(encoding="utf-8"))
    dropped = [k for k in hotkeys if k.startswith(HOTKEY_PREFIX_DROP)]
    for key in dropped:
        hotkeys.pop(key)
    write_json(out / "hotkeys.json", hotkeys)
    log.append(f"hotkeys.json — снято {len(dropped)} ключей ({', '.join(HOTKEY_PREFIX_DROP)})")

    # 6. theme + CSS snippet
    theme_src = src / "themes"
    for theme_dir in sorted(p for p in theme_src.iterdir() if p.is_dir()) if theme_src.is_dir() else []:
        dest = out / "themes" / theme_dir.name
        dest.mkdir(parents=True)
        for name in ("manifest.json", "theme.css"):
            if (theme_dir / name).exists():
                marked += copy_bundle(theme_dir / name, dest / name)
        licenses += copy_licenses(theme_dir, dest)
        log.append(f"themes/{theme_dir.name} — manifest.json + theme.css")
    snippet = src / "snippets" / "hide-files.css"
    if snippet.exists():
        (out / "snippets").mkdir(parents=True, exist_ok=True)
        copy_bundle(snippet, out / "snippets" / "hide-files.css")
        log.append("snippets/hide-files.css")

    # 7. daily-notes.json / templates.json ship only when every folder is part of the skeleton
    for name in ("daily-notes.json", "templates.json"):
        f = src / name
        if not f.exists():
            continue
        conf = json.loads(f.read_text(encoding="utf-8"))
        folders = [str(v) for k, v in conf.items() if k in ("folder", "template") and v]
        if folders and all(any(v == s or v.startswith(s + "/") for s in SKELETON_FOLDERS) for v in folders):
            write_json(out / name, conf)
            log.append(f"{name} — как есть")
        else:
            log.append(f"{name} — НЕ экспортирован: пути вне скелета ({', '.join(folders) or 'пусто'})")

    print("\n".join(log))
    print(f"\nЗаписано в {out}")

    hits = audit(out, stop_words)
    print("AUDIT:", "PASS" if hits == 0 else f"FAIL ({hits} совпадений)")
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
