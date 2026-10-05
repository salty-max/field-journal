# Explorer's Field Journal

A World of Warcraft addon: an Explorers' League field journal that fills in as
a character travels. Two books in one addon, each character keeping its own:

- **The Bestiary** (first): every kind of creature met, a naturalist's note per
  family, and the character's own record of each creature in it.
- **The Atlas** (second): the places visited, roads and flights taken, deaths
  and close calls, drawn on the world map.

Games: Classic Era (Hardcore, Season of Discovery), TBC Anniversary, World of
Warcraft: Forever. One source, one package per game, as Lorekeeper's Codex
(`bun run package`, two zips per release, CurseForge per game).

## Decisions (5 October 2026)

| Question | Decision |
|---|---|
| Shape | One addon, two books (Bestiary, Atlas). |
| Games | Classic Era / Hardcore / SoD, TBC Anniversary, Forever. |
| Voice | A naturalist of the Explorers' League (the Codex's world): a short note per family; the numbers come from play. |
| First | The Bestiary; the Atlas follows and reuses its position records. |
| Entries | A page per family (wolves, kobolds, the Defias…), listing every creature met in it with its own record. |
| Coverage | Beasts and monsters, humanoid peoples, rares and bosses (as trophies). Not critters or friendly NPCs. |
| Name | Explorer's Field Journal (repository `salty-max/field-journal`). |

## The Bestiary

### What a character records (SavedVariablesPerCharacter)

Per creature id, from the first meeting on:

- **Met:** first and last time, level and place (zone, subzone, map, x/y).
  Meeting = targeting or mousing over it.
- **Levels seen** (lowest, highest) and **places seen** (subzones, up to a few).
- **Slain:** count, first and last. Classic: the combat log's `PARTY_KILL` by
  the player or the pet. Forever (no combat log for addons): a kill is counted
  when its corpse is looted or targeted dead after a fight; less exact, said
  so in the book.
- **Loot:** items taken from its corpses, with counts (`LOOT_OPENED`,
  `GetLootSourceInfo` names the corpse).
- **Trophy:** rares and bosses get a mark, the date and level of the kill.

### How creatures are sorted into families

At runtime, from what the game says about the unit: `UnitCreatureType`
(Beast, Dragonkin, Demon, Elemental, Giant, Undead, Humanoid, Mechanical),
`UnitCreatureFamily` for beasts (Wolf, Spider, Raptor…), `UnitClassification`
(normal, elite, rare, rare elite, world boss). Static data adds what the game
doesn't say:

- **Humanoid peoples** (kobolds, gnolls, the Defias, the Scarlet Crusade…):
  creature id lists per people. The Codex's appendix already has 1,526 ids
  for 32 peoples; more peoples are added the same way.
- **Families of non-beasts** (oozes, harpies, nagas, silithid, golems, the
  elementals of each element, the undead kinds…): id lists, from the CMaNGOS
  Classic database (`creature_template`: type, family, rank), pinned to a
  commit, as the Codex's lore audit did.
- **Bosses:** dungeon and raid bosses by id (the database's rank and the
  dungeon lists), since the game calls most of them merely elite.

A creature no list knows (Forever's new ones, any gap) still lands in a page
by its type and beast family ("Unrecorded beasts: Wolf"), so nothing is lost.

### The book

- Families appear once one of their creatures is met; no counts of what
  remains (no spoilers), like the Codex.
- A family page: the naturalist's note, then each creature met: name, levels,
  where (with a link to the Atlas once it exists), slain, loot, trophy mark.
- Search, folding sections by creature type, a trophy shelf for rares and
  bosses.
- Tooltip line: "Field Journal: new" on creatures not yet met, slain count
  otherwise (a setting).
- Milestones (achievements style): first of each family, 100 kinds met, every
  beast family, every rare of a zone…

### Writing

About 100 to 150 naturalist's notes: each beast family, each people, each
kind of monster. Same rules as the Codex: original prose, lore up to Vanilla
from sources published before Wrath of the Lich King (Forever-only creatures
may use Forever's own texts), plain ASCII, reviewed against the game's texts.

## The Atlas (second)

### Decisions (5 October 2026)

| Question | Decision |
|---|---|
| Records | Places explored, deaths and close calls, flights and travel. No roads walked (decided 5 October 2026: not worth it in the long run, here or in WoWLocker). |
| Display | An Atlas tab in the book, plus optional pins (deaths, close calls) on the game's world map. |
| Text | A short note per zone by a second hand: a dwarf surveyor of the Explorers' League (roads, fords, passes, where not to camp). Same rules as the Bestiary's notes. |
| Spoilers | A zone appears once entered, then shows "n of m places explored", as the game's exploration achievements. |
| Milestones | Yes, in the Milestones tab. |
| Forever | Every zone is recorded from the game's own map data; notes for the original zones first, Forever's new ones after the launch (from `/codex scan` data). |

### What a character records

`FieldJournalChar.atlas`:

- **zones[uiMap]**: first and last visit (date, level), visits; **places[areaId]**:
  each place explored (date, level). Seeded quietly at first login from the
  fog of war the character has already lifted.
- **deaths[]**: date, level, zone, x/y, and what killed you (Classic: the last
  damage taken, from the combat log; Forever: the last hostile target, said to
  be less exact).
- **closeCalls[]**: health under 10% and alive a few seconds later: date,
  level, zone, x/y, the foe.
- **flights[]**: from and to (taxi nodes), date; counts per route. **crossings**:
  continent changes (boats, zeppelins, portals). **hearth**: each new bind.

### How (game APIs, on both clients)

- Places: `ZONE_CHANGED*` events; the zone from `C_Map.GetBestMapForUnit`, the
  places explored from `C_MapExplorationInfo.GetExploredAreaIDsAtPosition`. The
  seed samples each zone's map on a grid, spread over a few seconds.
- The list of a zone's places (the "m"): the client's `WorldMapOverlay` table
  (each overlay names the areas it reveals), per game build, from wago.tools,
  built into the data files like the creatures.
- Deaths: `PLAYER_DEAD`; close calls: `UNIT_HEALTH` on the player (secret
  values checked on Forever).
- Flights: `TakeTaxiNode` (hooked) names the destination, the taxi map the
  origin; arrival when the player leaves the taxi.
- The zone's map in the book: `C_Map.GetMapArtLayerTextures` (the world map's
  own tiles), the explored parts from `C_MapExplorationInfo`, our marks on top.
- World map pins: a data provider on `WorldMapFrame` with a pin template (an
  XML file in the addon), turned off in the settings.

### The book

A third tab, between the Bestiary and the Milestones. The list: continents,
the zones entered in each (with "n of m"). A zone's page: the surveyor's note,
the zone's map (explored parts, deaths, close calls, flight points), then the
record: first visit, the places explored, deaths and close calls, flights to
and from. A link to the Codex's page of the zone when the Codex is installed
and the page found.

### Milestones

Every place of a zone explored (one per zone, shown once entered), every zone
of a continent entered, flights taken (10, 50, 100), and feats (survive 10 close
calls, fly every route from a city...).

### Writing

About 45 notes for the original zones (and the capitals), by the surveyor: a
voice sample first, for approval; then the zones; then a review against
sources, as the Bestiary's.

### Steps

1. Data: zones per client, their continent and their places (UiMap,
   WorldMapOverlay, AreaTable from wago.tools, Classic Era and Forever builds).
2. The recording engine (`Atlas.lua`), with the simulation: places and the
   seed, deaths and close calls, flights, crossings, the hearth.
3. The book's Atlas tab: list, zone page, the map with its marks.
4. World map pins and their setting.
5. Milestones.
6. The surveyor's notes: sample, zones, review.
7. Release 0.3.0.

## Engineering (from the Codex)

- Content in Markdown (`content/families/<id>.md`: note, front matter with
  type, beast family or id lists), built to Lua by `scripts/build.ts`, one
  content file per game; `scripts/package.ts`, release script, CI, CurseForge
  workflow and the simulation (`luajit addon/test/sim.lua`, Classic and
  Forever modes) copied from the Codex.
- Forever: no combat log, secret values checked (`issecretvalue`), modern API
  fallbacks.
- Logo in the Codex's style.

## Status (5 October 2026)

- Released: v0.1.0 to v0.2.1 (the Bestiary, its look, milestones, the notes
  reviewed against sources), on GitHub and CurseForge (project 1728396).
- The Atlas, steps 1 to 6 done, not yet released: zone data for both games,
  the recording (places, deaths, close calls, flights, crossings, binds), the
  Atlas tab with each zone's map, world map pins, its milestones, and the
  surveyor's 46 notes.
- Next: confirm the world map pins (`/journal atlas`); review the surveyor's
  notes against sources; clean friendly pets out of the creature data;
  Forever's new zones and creatures after the launch (4 November).

## First steps

1. Repository from the Codex's skeleton (build, package, release, CI,
   simulation), empty content.
2. The recording engine (meet, slay, loot, trophies), with the simulation.
3. The family data: the CMaNGOS creature list sorted into families, the
   Codex's peoples, the boss lists.
4. The book (family list, family page, search, tooltip).
5. The notes, family by family, then review; release 0.1.0.
