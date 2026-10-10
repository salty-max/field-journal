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
- `data/zones-<game>.json` (`python3 scripts/zones.py`): the Atlas's zones from
  the client's map tables (UiMap, WorldMapOverlay, AreaTable on wago.tools; the
  Forever build pinned): continent, places (name, overlay offset, area ids).
  `atlas/<zone>.md`: the surveyor's note for a zone (front matter `zone:`).
- `data/rare-zones.json` (rare id -> uiMap) and `data/zones.csv` (the client's
  zones): the trophies-by-zone milestones (`python3 scripts/rare_zones.py`:
  the WoWWiki archive's "Rare mobs by zone", original-game section, else the
  rare's spawn points in the zones' map rectangles). Dungeon rares have none.
  `data/rare-zones-forever.json` (`python3 scripts/forever_rares.py`, from
  AllTheThings' Forever database, MIT, pinned): Forever's own rares (Zephras
  Isle's, the new ones of the old zones), in the Forever package's milestones
  only. No source gives Forever's new creatures' type, family or rank: the
  journal files them when met (`Creatures.lua`), from what the game says.
- `data/flora.json` (`bun run flora`, `scripts/flora.py`): the herbs and fish
  of the Plants and Fish tabs (being built, see PLAN.md): herbs with their
  nodes, Herbalism skill (the client's Lock table) and zones (the nodes'
  spawns, placed by the Atlas's places of each zone); fish with their zones,
  subzones, dungeons, schools and seasons, and the weighed catches as kinds.
- `notes/herbs.md`, `notes/fish.md`: the naturalist's note for every herb and
  fish ("## <item id> <name>", then paragraphs; plain ASCII; the build refuses
  a missing or unknown one). Places only from the data, uses only from the
  game's recipes of the original game.
- `content/<section>/_section.md`: a creature type (title, type, order);
  `content/<section>/<family>.md`: a family (id, title, order, `match:` rules,
  the naturalist's note). Rules, in priority: ids, people, name (regex, the section's type) and beast
  (CreatureFamily id; for a beast, the game's own family first), model (a
  family of its own type that the creatures of its model were sorted into by
  those, when they agree; never for the undead), name of another type (a
  family with `anytype: true`), fallback.
- `scripts/build.ts`: sorts every creature into a family, reports overlaps
  (`--verbose`) and families without a note, writes
  `addon/FieldJournal/Data_Classic.lua` and `Data_Forever.lua` (generated,
  committed; `--check` fails if stale).
- `addon/FieldJournal` is one package for every game, installable as is: each game
  loads its own TOC (`FieldJournal_Vanilla.toc`: Classic Era, 11509; `_TBC.toc`:
  TBC Anniversary, 20506; `_Camelot.toc`: Forever, 16001), the same but for
  the interface and the game's data (`Data_Classic.lua` or
  `Data_Forever.lua`). `scripts/package.ts` (`bun run package`) checks they
  agree and zips `dist/FieldJournal.zip` for a test in the game.
- `addon/FieldJournal/`: `Core.lua` (the journal's schema; the events every
  file listens to: `ns.on`, and `ns.onUnit` for a unit event heard for one
  unit only; the login and its migrations; `/journal`), `Creatures.lua` (the
  Bestiary's records: a creature met (target, mouseover) is a sighting
  (`seen`), it joins the book on its first kill, its family with it (the
  families met kept by their id, never their place in Data.lua's list, and
  rebuilt from the creatures at each login: a creature can move to another
  family, a family can be added, without harm to a saved journal); kills (mine, my pet's or my
  group's) from `PARTY_KILL` (an event of its own on Forever and Classic since
  1.15.9), else the combat log, and a quest's count gone up for a creature no
  kill told (another's blow on one I tagged, which the game credits);
  loot from the loot window, trophies; a
  chat line per new creature, a sound only for trophies), `Atlas.lua` (places
  explored from the fog lifted, `C_MapExplorationInfo`; deaths, close calls,
  flights, crossings, binds), `Flora.lua` (fish and herbs), `Achievements.lua`
  (milestones: tallies, every family of a type, feats, every rare of a zone,
  the Atlas's and the flora's; the game's achievement toast, fanfare and a
  chat line; no spoilers before a type or zone is met). The book: `Kit.lua`
  (a copy of the kit shared with Hearthtale and the Codex, ~/code/addon-kit:
  the books' look, window, dialog and tabs; never edited here: `bun run
  kit:sync` after changing the kit, `bun run kit:check` to verify),
  `Book.lua` (the journal's theme on the kit, the window, its tabs
  registered by their files with `ns.addTab`, links in chat, and the kit
  every tab is made of, `ns.ui`; a tab's own select under the search box,
  registered with its tab, `filter = { default, options() }`, its choice
  `ns.filterOf(n)`: the Bestiary's order, the Atlas's continent; `newList` for the list on the left,
  `newPage` for the page on the right),
  `BestiaryBook.lua` (still portraits from the data's display ids,
  `SetPortraitTextureFromCreatureDisplayID`), `FloraBook.lua` (Fish and
  Plants), `AtlasBook.lua` (zones by continent, the zone's map art with its
  explored overlays and marks), `MilestonesBook.lua`. `WorldMapPins.lua`
  (deaths on the game's world map), `Hints.lua` (tooltip line),
  `Settings.lua` (each character's settings, the kit's profiles: a profile
  "Name - Realm" in FieldJournalSettings, copied from another character of
  this game or from a code `FJ1:...`, `/journal export` and `/journal import
  CODE`; a character who kept a journal before starts from the account's old
  values; the Options page, its "Copy settings from"), `Welcome.lua` (the
  kit's welcome page, once per character, `/journal welcome`: the logo,
  `Media/Logo.tga` from `assets/logo.png` with magick, what the journal is,
  the choices, the sound in a select; the packages carry `Media/`),
  `Minimap.lua`. A game function is checked before use only
  where the clients differ; the test game has every one the addon calls.
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
- Classic and Forever are separate accounts of the world. In family notes,
  Atlas notes and herb/fish notes, prefix a paragraph with `[classic]` or
  `[forever]` when the accounts differ. Unmarked paragraphs belong to both.
  Selection happens at build time; markers and the other world's paragraphs
  never reach the installed book. Each available note must retain text in
  both games. Use Forever's quests and announcements for its additions;
  a new map name alone does not establish new history.
- The Atlas has a dwarf surveyor's voice: terrain, routes, landmarks and the
  experience of crossing them. Keep its work distinct from the naturalist's
  creatures and the Codex archivist's history. Herb and fish notes complement
  the location lists already shown by the book; they need not repeat them.
- No spoilers: families appear once met; no totals of what remains.

## Commands

```bash
bun run build | check | package
bun run creatures          # regenerate data/creatures.json (pinned database)
python3 scripts/rare_zones.py    # then data/rare-zones.json (each rare's zone)
bun scripts/build.ts --verbose   # per-family counts, overlaps, unsorted
```

## Conventions

- Conventional Commits, lowercase subjects; no AI co-author trailers.
- Commit locally; ask before any push, release or deploy.
- Lua: `bun run format:lua` (StyLua, `stylua.toml`) and `bun run lint:lua`
  (selene, `selene.toml`; the game's globals in `wow.yml`: add one there when
  the addon calls a new game function). Both run in `bun run check` and CI.
- Release: `scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md` (main
  pushed first); GitHub Actions runs the BigWigs packager (`.pkgmeta`):
  the zip on GitHub, CurseForge (the TOCs' `X-Curse-Project-ID`, secret
  `CURSEFORGE_TOKEN`) and Wago Addons (`X-Wago-ID`, secret
  `WAGO_API_TOKEN`). `--hold`: GitHub alone (variable `HOLD_STORES`); the
  stores later: `gh workflow run release.yml -f tag=vX.Y.Z`.
