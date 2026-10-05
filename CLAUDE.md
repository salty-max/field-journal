# Explorer's Field Journal

A World of Warcraft addon: an Explorers' League field journal that fills in as
a character travels. Book one, the **Bestiary**: every creature met, slain and
looted, sorted into families with a League naturalist's note per family. Book
two, the **Atlas**, comes later. Plan and decisions: PLAN.md. Sister project:
Lorekeeper's Codex (~/code/lorekeepers-codex), same engineering and voice.

## Layout

- `data/creatures.json`: the creatures of the original world (id, name, type,
  beast family, rank, levels), from the CMaNGOS Classic database pinned to one
  commit (`scripts/creatures.py`, `bun run creatures`). Leaves out friendly
  folk (either side's factions, vendors, quest givers), critters, totems and
  the database's helpers. A community reconstruction, not Blizzard's data.
- `data/peoples.json`: creature id lists per people (from the Codex's research).
- `content/<section>/_section.md`: a creature type (title, type, order);
  `content/<section>/<family>.md`: a family (id, title, order, `match:` rules,
  the naturalist's note). Rules, in priority: ids, people, name (regex, the
  section's type unless `anytype: true`), beast (CreatureFamily id), fallback.
- `scripts/build.ts`: sorts every creature into a family, reports overlaps
  (`--verbose`) and families without a note, writes
  `addon/FieldJournal/Data_Classic.lua` and `Data_Forever.lua` (generated,
  committed; `--check` fails if stale).
- `scripts/package.ts` (`bun run package`): `dist/classic`, `dist/forever`,
  one installable addon per game (its data file as `Data.lua`, its TOC from
  the `@INTERFACE@` template: the source folder is not installable).
- `addon/FieldJournal/`: `Core.lua` (records: meet on target/mouseover, slay
  from the combat log or on Forever from loot/dead targets it fought, loot from
  the loot window, trophies; a chat line per new creature, a sound only for
  trophies; `/journal`), `Book.lua` (the book: entries with 3D portraits from
  the data's display ids, `PlayerModel:SetDisplayInfo` as the quest window),
  `Hints.lua` (tooltip line), `Settings.lua`, `Minimap.lua`.
- `addon/test/sim.lua`: fake WoW API, a dwarf's first hunts, every recording
  asserted. `FOREVER=1` runs it as Forever (no combat log, secret values).

## Writing notes (the product is the text)

- Voice: a naturalist of the Explorers' League (the Codex's archivist's
  colleague): observant, dry, fond of the creatures it describes. Two to four
  short paragraphs per family: what they are, where and how they live, what a
  traveller should know. The player's own numbers follow the note on the page.
- Lore scope as the Codex: up to Vanilla, from sources published before Wrath
  of the Lich King; Forever-only families may use Forever's own texts. Original
  wording. Plain ASCII (the build rejects others).
- No spoilers: families appear once met; no totals of what remains.

## Commands

```bash
bun run build | check | package
bun run creatures          # regenerate data/creatures.json (pinned database)
bun scripts/build.ts --verbose   # per-family counts, overlaps, unsorted
```

## Conventions

- Conventional Commits, lowercase subjects; no AI co-author trailers.
- Ask before committing, pushing or releasing.
- Release: `scripts/release.sh [--version X.Y.Z] NOTES.md` (main pushed
  first); GitHub Actions publishes both zips and uploads them to CurseForge
  once the project exists (variable CURSEFORGE_PROJECT_ID, secret
  CURSEFORGE_TOKEN).
