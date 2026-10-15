# Yonder

A World of Warcraft addon: an Explorers' League field journal that fills in as
a character travels. Called Explorer's Field Journal (folder `FieldJournal`)
until 0.8.0; renamed on 13 October 2026 because Field Journal: Forever (by
Mangzane, on CurseForge since 29 September) ships the same folder, so the two
replaced each other and shared a saved file. Yonder's globals are its own
(`YonderChar`, `YonderSettings`, `Yonder*` frames, `/yonder`, `yonder:`
links). The handover, `addon/FieldJournal` (shipped beside `addon/Yonder`:
`.pkgmeta`, `scripts/package.ts`), keeps the old name so the game loads the
old saved files (`FieldJournalChar`, `FieldJournalSettings`) once more; at
login `adopt` (Core.lua) takes them under the new names and says so in chat
(a player's copied `FieldJournal.lua` works the same), and `oldSelf` turns
the old addon itself off when it runs beside Yonder (told by its title; a
manual install over the old folder keeps its Forever TOC, and two journals
then record at once), for every character of the game, and says so. The
handover has Classic Era and TBC TOCs only and one file, `YonderHandover.lua`:
on Forever, Field Journal: Forever owns a `FieldJournal` folder
(`FieldJournal.toc`), which no Camelot TOC of ours may shadow, and Forever's
beta journals don't outlive the beta; `package.ts --check` refuses anything
more. Drop the handover in a later release (the user decides when), and with
it `adopt`'s chat line. The repository is salty-max/yonder and its local
folder ~/code/wow-addons/yonder (both field-journal until 13 October 2026).

The **Expeditions** first (the book opens on them): each zone's riddles, solved on the spot, and its quarry, a rare to track down. The
**Bestiary**: every creature met, slain and looted, sorted into families with
a League naturalist's note per family. The **Atlas**: the zones explored, a
dwarf surveyor's note each. **Fish** and **Plants**, and the **Milestones**.
Plan and decisions: PLAN.md. Sister project: Lorekeeper's Codex
(~/code/wow-addons/lorekeepers-codex), same engineering and voice.

## Layout

- The game's data comes through wow-data (`../wow-data`, beside this folder:
  its pins, its one cache, its databases; the Python scripts read them with
  `../wow-data/py/wowdata.py`). No script here pins or downloads a source.
- `data/creatures.json`: the creatures of the original world (id, name, type,
  beast family, rank, levels), from wow-data's Classic Era database (Questie's
  and the CMaNGOS Classic database's; `scripts/creatures.py`, `bun run creatures`). Leaves out friendly
  folk (either side's factions, vendors, quest givers), critters, totems and
  the database's helpers. A community reconstruction, not Blizzard's data.
- `data/peoples.json`: creature id lists per people (from the Codex's research).
- `data/zones-<game>.json` (`python3 scripts/zones.py`): the Atlas's zones from
  the client's map tables (UiMap, WorldMapOverlay, AreaTable: wow-data's
  databases, each game's pinned build): continent, places (name, overlay
  offset, area ids).
  `atlas/<zone>.md`: the surveyor's note for a zone (front matter `zone:`).
  Also every area's English name by id (`areaNames`, only to read the
  journals of before 15 October 2026) and each flight point's zone
  (`taxiZone`, node id -> uiMap, by the client's UiMapAssignment). The
  journal keeps ids only, never a game name (a player's excepted): places as
  `"a<area>"` or `"w<building area>"` (a pair `"zone|sub"`), flights by their
  points' ids, routes `"<from>><to>"`, a bind, a death's foe, a creature's
  type and family by their ids. The game names the areas, types and families
  by id in the client's language (`C_Map.GetAreaInfo`, `C_CreatureInfo`);
  the rest by the language's name files (below). Older journals' names are
  turned into ids at the login (`mendNames`, `Core.lua`), each language's on
  a client of that language.
- `data/rare-zones.json` (rare id -> uiMap; the zones' names from
  `data/zones-classic.json`): the trophies-by-zone milestones (`python3 scripts/rare_zones.py`:
  Questie's zone for the rare, else its spawn points in the zones' map
  rectangles). Dungeon rares have none.
  `data/rare-zones-forever.json` (`python3 scripts/forever_rares.py`, from
  wow-data's Forever database: its rares Classic's world doesn't have, by
  Questie's zones): Forever's own rares (Zephras Isle's, the new ones of the
  old zones), in the Forever package's milestones only. No source gives
  Forever's new creatures' type or family: the journal files them when met
  (`Creatures.lua`), from what the game says.
- `data/flora.json` (`bun run flora`, `scripts/flora.py`): the herbs and fish
  of the Plants and Fish tabs (being built, see PLAN.md): herbs with their
  nodes, Herbalism skill (the client's Lock table) and zones (the nodes'
  spawns, placed by the Atlas's places of each zone); fish with their zones,
  subzones, dungeons, schools and seasons (their areas by id, named by the
  book), and the weighed catches as kinds.
- `notes/herbs.md`, `notes/fish.md`: the naturalist's note for every herb and
  fish ("## <item id> <name>", then paragraphs; plain ASCII; the build refuses
  a missing or unknown one). Places only from the data, uses only from the
  game's recipes of the original game.
- `expeditions/<zone>.md` (named as the atlas's, top level: build.ts reads
  every `content/` folder as a Bestiary section): a zone's riddles (the
  Expeditions, PLAN.md): front matter in YAML (`zone`, `home` for a starting
  zone or capital, `riddles`: id, tier, `faction` (a town's, or the side a
  keeper doesn't attack), `gestures`
  (emote tokens) or `reading`, `night`, the spot: `object`, `creature`,
  `trigger` or `area` (with an `anchor` where the area has no map overlay),
  `found: target` for a keeper met by speaking to it or one that walks,
  `hint_area`, `danger`, `sources`; `quarry: { id, sources }` in a zone with
  rares, never a capital (a creature of Forever's own, which the data doesn't
  know, adds its `name`, `level`, `rank` and `model`); `client: forever` for a
  zone of Forever's own (Zephras Isle: creatures and sub-areas only); never what a quest leads to, class quests aside,
  never a kill, never the same deed twice in a zone, never on Forever's new
  quests' road (the resolver checks these three:
  PLAN.md, Reworked and After the first test), then `## <id>` sections: the verse, `? ` the
  first hint, `= ` the note, `+ ` the margin; `## quarry`: its poster (verse,
  note, margin, no hint); plain ASCII.
  `scripts/expeditions.py` resolves the spots from the game's data into
  `data/expeditions.json` (committed): an object's spawns (dump and Wowhead
  alike, inside the hint circle), a creature's spawn (and whether it walks),
  a trigger, a sub-area's ids; a quarry's haunts (its spawns that Wowhead
  places too, and the paths they walk, gathered into circles); each zone's
  size in yards and sub-areas; the client's emote tokens. A zone of Forever's
  own is placed on Forever's client tables, its creatures from Questie's
  Forever (no license: credited) where Wowhead's Forever database places them
  too. Wowhead's points (the cross-check of every spot, a quarry's
  sightings) are frozen in wow-data (`bun ../wow-data/bin/wowhead-points.ts`:
  a new riddle's creature or object fetched there first). Rerun it after changing a spot or a hint circle (the
  build refuses a stale one). `scripts/expeditions.ts` (for build.ts) checks
  every riddle and writes the answers as fingerprints only (salted FNV-1a of
  5-yard cells, sub-areas, the keeper, the gestures), the texts read once
  solved veiled.
- `content/<section>/_section.md`: a creature type (title, type, order);
  `content/<section>/<family>.md`: a family (id, title, order, `match:` rules,
  the naturalist's note). Rules, in priority: ids, people, name (regex, the section's type) and beast
  (CreatureFamily id; for a beast, the game's own family first), model (a
  family of its own type that the creatures of its model were sorted into by
  those, when they agree; never for the undead), name of another type (a
  family with `anytype: true`), fallback.
- `scripts/build.ts`: sorts every creature into a family, reports overlaps
  (`--verbose`) and families without a note, writes
  `addon/Yonder/Data_Classic.lua` and `Data_Forever.lua` (generated,
  committed; `--check` fails if stale).
- `addon/Yonder` is one package for every game, installable as is: each game
  loads its own TOC (`Yonder_Vanilla.toc`: Classic Era, 11509; `_TBC.toc`:
  TBC Anniversary, 20506; `_Camelot.toc`: Forever, 16001), the same but for
  the interface and the game's data (`Data_Classic.lua` or
  `Data_Forever.lua`). `scripts/package.ts` (`bun run package`) checks they
  agree and zips `dist/Yonder-<version>.zip` for a test in the game
  (`git describe`: the tag, or v0.7.3-2-g1234abc between two, -dirty if
  changed); a release's is `Yonder-vX.Y.Z.zip`.
- `addon/Yonder/`: `Core.lua` (the journal's schema; the events every
  file listens to: `ns.on`, and `ns.onUnit` for a unit event heard for one
  unit only, each listener protected: its error reported, the others still
  run; the login and its migrations; the login's line in chat, `ns.loginLine`:
  riddles solved, quarries, creatures, never what remains, and how to open the
  journal, as the Codex's; `/yonder`), `Creatures.lua` (the
  Bestiary's records: a creature met (target, mouseover) is a sighting
  (`seen`), it joins the book on its first kill, its family with it (the
  families met kept by their id, never their place in Data.lua's list, and
  rebuilt from the creatures at each login: a creature can move to another
  family, a family can be added, without harm to a saved journal); kills (mine, my pet's or my
  group's) from `PARTY_KILL` (an event of its own on Forever and Classic since
  1.15.9), else the combat log, and a quest's count gone up for a creature no
  kill told (another's blow on one I tagged, which the game credits);
  loot from the loot window (read at `LOOT_READY`, before auto loot or a
  fast-loot addon empties it, and again at `LOOT_OPENED`), drop rates
  (`rec.drops`: of my kills whose corpse I looted, its window's first opening,
  or found empty, `CanLootUnit` a moment after the kill, solo only, a corpse
  found empty and looted after all counting its items, once; each item once a
  corpse; `ns.dropRate`, on a spoil's tooltip, saying when an item dropped
  only before the count began), trophies; a
  chat line per new creature, a sound only for trophies), `Atlas.lua` (places
  explored from the fog lifted, `C_MapExplorationInfo`; deaths, close calls,
  flights, crossings, binds), `Flora.lua` (fish and herbs, read from the loot
  window as the Bestiary's loot is; `/yonder probe`: the next loot window as
  each of its events finds it), `Achievements.lua`
  (milestones: tallies, every family of a type, feats, every rare of a zone,
  the Atlas's, the flora's and the expeditions'; a banner, the fanfare and a
  chat line; no spoilers before a type or zone is met; an expeditions' one
  that changed riddles leave undone withdrawn at the login, to be earned
  again). The book: `Kit.lua`
  (a copy of the kit shared with Hearthtale, the Codex and Second Wind,
  ~/code/wow-addons/addon-kit: the books' look, window, dialog and tabs, the
  list and the page with every part of a page, the board, the banners; never edited here: `bun run
  kit:sync` after changing the kit, `bun run kit:check` to verify),
  `Book.lua` (the journal's theme on the kit, the window, its tabs
  registered by their files with `ns.addTab` (the Expeditions first, the
  book opening on them), links in chat, and the kit
  every tab is made of, `ns.ui`; a tab's own select under the search box,
  registered with its tab, `filter = { default, options() }`, its choice
  `ns.filterOf(n)`: the Bestiary's order, the Atlas's continent; `newList` for the list on the left,
  `newPage` for the page on the right: the kit's `K.list` and `K.page`, its
  parts: rows, sections, cards, paragraphs, a strip of figures, items'
  icons, names to pick, a medal on a round picture),
  `BestiaryBook.lua` (still portraits from the data's display ids, each in
  its rank's ring, the kit's `K.rankRing`: elites, from the data's `elites`
  (an elite is no trophy, never in `ranks`), gold; rares silver; bosses rose;
  `SetPortraitTextureFromCreatureDisplayID`; a family's page: figures and a
  card per creature; a creature's: figures, the creature turning in its
  frame, its record, its spoils), `FloraBook.lua` (Fish and Plants: figures,
  the zones as names that open the Atlas, the last finds as cards), `AtlasBook.lua` (zones by continent; a zone's page: the
  surveyor's note, its figures, its map art with its explored overlays and
  marks, drawn by `ZoneMap.lua`, shared with the Expeditions, the places
  explored to pick out on it, its expedition, what grows and bites there as
  items, deaths and close calls as cards; the travels: figures, the lands,
  the places discovered lately), `ExpeditionsBook.lua` (the riddles by zone; a zone's page in
  words, cards and its map; a riddle's page, its verse set apart, its hints
  asked for through the game's confirmation, its seal, note and margin; a
  quarry's poster, the creature turning in its frame), `ExpeditionsPin.lua`
  (a riddle or quarry pinned to the screen: a card to drag, closed by its
  cross), `Toasts.lua` (the kit's banners, among the game's alerts: a
  milestone's, a riddle's (its seal its ring: gold, silver, copper; iron
  till solved), a quarry's, each its own),
  `MilestonesBook.lua` (the Achievements tab, "Hauts faits" in French: milestones in the code and the saved journal, achievements to the player, as the Codex's; the kit's board: figures on top, each group's
  picture and count, its ring gold once earned, iron till then). Every page is made of the
  same parts (the kit's, shared by the family's books).
  `Expeditions.lua` (the riddles' records and their
  solving: each second where the reader stands, a gesture by hooking
  `C_ChatInfo.PerformEmote` (the chat's, the menu's; `DoEmote` where there is
  none), a reading at `ITEM_TEXT_BEGIN`, a keeper spoken to (a window it
  opens when spoken to: `GOSSIP_SHOW`, quests, wares, lessons, flights, its
  `npc` unit), a keeper a gesture asks for targeted near
  (`CheckInteractDistance`; never one only under the mouse), the night by
  the game's clock; outside combat,
  never from a taxi or as a ghost;
  `/yonder where`). `WorldMapPins.lua`
  (deaths, close calls and the hints' circles on the game's world map; an
  error of its own said once in chat and kept for /yonder where, which
  Forever's map would swallow), `MinimapCircles.lua` (the hints' circles on
  the minimap: `ns.hintCircles`, the zone's yards from the data, the
  minimap's span from the game or its zoom, turning with it), `Hints.lua` (tooltip line),
  `Settings.lua` (each character's settings, the kit's profiles: a profile
  "Name - Realm" in YonderSettings, copied from another character of
  this game or from a code `YD1:...` (an old `FJ1:` taken too), `/yonder export` and `/yonder import
  CODE`; a character who kept a journal before starts from the account's old
  values; the Options page, its "Copy settings from"), `Welcome.lua` (the
  kit's welcome page, once per character, `/yonder welcome`: the logo,
  `Media/Logo.tga` from `assets/logo.png` with magick, what the journal is,
  the choices, the sound in a select; the packages carry `Media/`),
  `Minimap.lua`. The opt-in that shares what the game tells of the world
  (the kit's `K.collect`: quests' texts, creatures' facts, NPCs' lines, loot
  by source; off until the player ticks it on the welcome page or the
  Options page) keeps it account-wide in `YonderCollect`, which Ravenpost
  sends to the addons' database. A game function is checked before use only
  where the clients differ; the test game has every one the addon calls.
- Languages: every word the addon shows goes through `L["..."]` (the kit's
  `K.L`; plurals through `ns.kit.plural`); link and colour codes stay outside
  the words. The TOCs load `Locale.lua` (`ns.translate`, `ns.names`) and
  `Text_[TextLocale].lua` after the data: `scripts/locales.ts` (in `build` and
  `check`) writes them from `i18n/<locale>/`. Every language, English one of
  them, has its name files, each complete (no "only what differs from the
  English", no English fallback): `creatures.json` (every creature by id,
  each game's, `python3 scripts/creature_names.py <locale>`), `taxi.json`
  (the flight points, `python3 scripts/taxi_names.py <locale>`),
  `subzones.json` (the building areas, `python3 ../addon-kit/subzones.py
  <locale>`), `catches.json` (the weighed catches' kinds, `python3
  scripts/catch_names.py <locale>`: each language's pattern, every weight of
  a kind agreeing, else an error), all from wow-data's databases, and
  `areas-by-hand.json` (an area the client misnames); the riddles' and
  quarries' answers that are the thing's own name (`data/expeditions.json`'s
  `names`, an area riddle's by its area's id), in every language's file,
  translated or not; `ns.names` loads them. A translation besides
  (words, sections, families, atlas, herbs/fish notes, expeditions with their
  riddles veiled as the English; `ns.translate`), the English its source:
  `glossary.json` and `classic.json`: `../addon-kit/glossary.py`, with
  `glossary-by-hand.json`'s names no table has). A name the glossary holds
  that an English text names is in its translation as the game writes it
  (`scripts/names.ts`, in `--check`; the exceptions, with their reason, in
  `names-ok.json`), and a riddle's answer that is the thing's own name is the
  game's, by its id (`data/expeditions.json`'s `names`): a translation's `@`
  only for an answer of its own. Each
  translation records its English source's hash (`--stamp`). Everything the
  journal keeps reads in the client's language of now, by its id:
  `ns.creatureName`, `ns.areaLabel` and `ns.placeText`, `ns.routeText`,
  `ns.familyTitle`; a creature's name is kept only for one no language's
  list names. A creature the data doesn't file (a new one of Forever's) is
  filed by its family's id, then its model's (`modelFamilies`: the family
  the data's creatures of that model and type were given), its name's
  English words last. French done 13
  October 2026; German the 14th, flagged (a first translation, corrections
  welcome): "du", the game's own German names (most of Classic's cities and
  many places stay English on a German client), `$gmasc:fem;` where a line
  speaks to the reader, quotes the game has in German (wow-data's `speech`)
  taken as it writes them.
- `addon/test/sim.lua`: fake WoW API, a dwarf's first hunts, every recording
  asserted. `FOREVER=1` runs it as Forever (no combat log, secret values).

## Writing notes (the product is the text)

- Voice: a naturalist of the Explorers' League (the Codex's archivist's
  colleague): observant, dry, fond of the creatures it describes. Two to four
  short paragraphs per family: what they are, where and how they live, what a
  traveller should know. The player's own numbers follow the note on the page.
- No semicolons in prose, in any language (the user's rule, 14 October
  2026): two sentences, or a comma, or a rewrite for a list. The gender
  tokens' own `;` stay. Research notes (`sources:`) may keep theirs.
- Lore scope as the Codex (loosened on 12 October 2026): the past up to the
  vanilla era from any source (the games, novels, comics, RPG books,
  Chronicle), nothing anachronic to vanilla or Forever; Forever-only families
  may use Forever's own texts. Original wording. Plain ASCII (the build
  rejects others).
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

- `.github/workflows/game-data.yml`: daily and by hand, wow-data's
  `addon-data.yml` builds the game data again from wow-data's pins (the zones, creatures, herbs and fish, rares' zones, the expeditions' spots (a new build's quests checked against every riddle's road), the names in every language, then `bun run build`);
  a pull request when a generated file changes, the checks run on it, then
  rebased onto main by itself and told to the owner's phone in words
  (Ravenpost's inbox). The generators' list lives there: a new one goes in too.

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
