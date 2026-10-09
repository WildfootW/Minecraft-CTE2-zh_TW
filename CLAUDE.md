# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Taiwanese Traditional Chinese (zh_tw) localization for the Minecraft modpack **Craft to Exile 2 v1.1.3** (MC 1.20.1 / Forge). It contains only translation text (lang JSON, FTB Quests SNBT, one MineMenu config) plus a PowerShell installer/builder. There is no application code, no test suite, and no linter. README, docs, and git commit messages are written in Traditional Chinese; keep commit messages in zh-TW to match.

## Commands

All build/install logic lives in `setup.ps1` (PowerShell 5.1 compatible, also runs under `pwsh` on Linux in CI).

```powershell
# Build the resource pack zip only -> dist/CTE2-v1.1.3-zh_tw-resourcepack.zip
powershell -ExecutionPolicy Bypass -File setup.ps1 -Build

# Build the full bundle (resource pack + ftbquests/ + extras/ + setup.ps1) -> dist/CTE2-v1.1.3-zh_tw-full.zip
powershell -ExecutionPolicy Bypass -File setup.ps1 -BuildFull

# Interactive installer (detects CurseForge instance, installs/uninstalls into the game)
powershell -ExecutionPolicy Bypass -File setup.ps1
```

`dist/` and `*.zip` are gitignored. CI (`.github/workflows/build.yml`) runs `-BuildFull` on every push to the `v1.1.3` branch and attaches the zips to the GitHub Release on `v*` tags, so zips are never committed.

Quick validation after editing translations (no formal tests exist):

```bash
# Lang files must be valid JSON
python -I -c "import json,sys; json.load(open(sys.argv[1],encoding='utf-8'))" resourcepack/assets/mmorpg/lang/zh_tw.json

# Quest SNBT line count must match the original English file exactly (see rules below)
wc -l ftbquests/chapters/act_i.snbt
```

## Layout and how the pieces fit together

- `resourcepack/` — the whole resource pack as shipped: `pack.mcmeta` + `assets/<namespace>/lang/zh_tw.json` for about 830 namespaces, plus Patchouli book translations. It contains both this project's own translations (the 8 CTE2 core mods such as `mmorpg`, `cte_essentials`, `roe_weapons`, `dungeon_realm`, `library_of_exile`, plus ~55 mods nobody else had translated) and the community packs folded in on 2026-10-10 (previously a separate `community/` tree). Community-origin content is not MIT (see README); their license files live in `docs/community-licenses/`.
- `ftbquests/` — translated FTB Quests files (`chapters/*.snbt`, `reward_tables/*.snbt`, `chapter_groups.snbt`). Installed by copying over `<instance>/config/ftbquests/quests/`.
- `extras/minemenu/menu.json` — MineMenu (H-key radial menu) config. Chinese here is stored as `\uXXXX` escapes on purpose, because the mod reads the file without assuming UTF-8.
- `docs/` — translation rules and glossary (see below) and `title_map.tsv` (English quest title → zh-TW, tab separated).

**Build** (`Build-Pack` in `setup.ps1`) simply zips `resourcepack/`. Minecraft namespaces must be lowercase; an `assets/<Name>/` dir with capitals is silently ignored by the game, so never add one. Lang keys are global across namespaces: a key defined in `assets/mmorpg/lang/zh_tw.json` also applies to `library_of_exile.*` keys, so always check for an existing translation across all files before adding one.

The zip is written with a custom `Write-Zip` that forces forward-slash entry names. .NET's `CreateFromDirectory` emits backslashes on Windows and Minecraft then cannot read the pack, so keep using `Write-Zip` for any new archive.

**Finding untranslated keys**: the only reliable method is to compare the built zip against every `en_us.json` in `<instance>/mods/*.jar` plus the modpack's `config/openloader/resources/resources.zip`, treating jar-internal `zh_tw.json` files as covered. Comparing per-namespace against the source tree misses keys and over-counts coverage.

## Translation rules (must follow when editing text)

Full rules and glossaries: `docs/語言檔翻譯規範.md` (lang JSON) and `docs/任務書翻譯規範.md` (quest SNBT). Key points that break the game if violated:

- **SNBT quest files**: output must have exactly the same number of lines as the English original, line-for-line. Only translate the string inside `title:`, `subtitle:`, `description: [...]` entries, `hover:` and `text:`. Never touch keys, `id:`, `icon:`, `item:`, `dependencies:`, numbers, coordinates, embedded JSON strings (e.g. `mmorpg_gear: "{...}"`), or tab indentation. Keep `&a`/`&r` style codes, `\"`, `\n`, `\\` intact.
- **Lang JSON**: keys unchanged and in the same order; placeholders (`[VAL1]`, `[calc:xxx]`, `%s`, `%1$s`, `%d`) and `§x` color codes preserved verbatim; literal Chinese characters, not `\uXXXX` (opposite of `menu.json`). UTF-8 without BOM.
- **Terminology**: Path of Exile concepts use Garena Taiwan 流亡黯道 terms (Ascendancy=昇華, Unique=傳奇, Affix=詞綴, Currency=通貨, Chaos Orb=混沌石, Salvage=分解, Dungeon=地城, Boss=首領 …). Minecraft vanilla terms use official Taiwan names (Nether=地獄, The End=終界, Creeper=苦力怕, Netherite=獄髓). Taiwan usage only, no mainland-China vocabulary. Mod names stay in English.
- **Quest ↔ item alignment**: quest text and item/skill names must match. When a lang value is a quest title or named item, use the translation already fixed in `docs/title_map.tsv`.
- **Two English sources**: besides each mod jar's `en_us.json`, the modpack ships its own override pack at `<instance>/config/openloader/resources/resources.zip`. Modpack-custom spells, stats, unique gear, villager dialogue etc. exist only there, and it also rewrites some jar strings (Spell → Skill, aura gem → Augment Gem). Always diff against both when looking for untranslated keys. Lang keys are global across namespaces, so compare against the merged table of all `zh_tw.json` files, not per namespace.

`.gitattributes` sets `* -text` so every file round-trips byte-exact; do not let tooling convert line endings.
