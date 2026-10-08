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

Per creature id, from its first kill on (7 October 2026: before, from the
first meeting); what was seen of it before (`seen`) comes with it:

- **Met:** first and last time, level and place (zone, subzone, map, x/y).
  Meeting = targeting or mousing over it.
- **Levels seen** (lowest, highest) and **places seen** (subzones, up to a few).
- **Slain:** count, first and last: the player's or the pet's killing blow,
  from `PARTY_KILL` (killer, victim), an event of its own on Forever and
  Classic since 1.15.9; else the combat log's line. On Forever, creature identity is secret inside instances
  (Midnight's rules): nothing there can be recorded.
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

## Fish and Plants (third and fourth)

### Decisions (6 October 2026)

| Question | Decision |
|---|---|
| Shape | Two new tabs after the Bestiary, before the Atlas: Fish, and Plants. |
| Plants | Every herb that reaches the bags counts (gathered, looted, bought, received); the gathered ones are marked. The game tells addons nothing of a node passed or hovered, so nothing is "seen". |
| Fish | Each catch: zone and subzone, first catch, count, the hour (day or night), from a school or open water. Junk and oddities are not entries; the weighed catches ("32 Pound Catfish") are, one per kind, with the heaviest landed. |
| Text | A note per species by the League's naturalist (where it grows or bites, its uses, its lore), reviewed against sources like the family notes. |
| Where found | From the game data (CMaNGOS), shown once the species is found: no spoilers before. |
| Milestones | Tallies (first catch, first herb, 10, 25, every kind), feats (Black Lotus, a Deviate Fish, a school of each kind...), and by zone or continent (every fish of a continent's waters, every herb of a zone). |
| Atlas | A zone's page lists what grows and bites there: the found ones named, the rest counted. |
| Scope | Vanilla first; Forever's new herbs and fish after its launch (4 November), as for the creatures. |

### What a character records (SavedVariablesPerCharacter)

- **Fish**: `fish[itemId] = { first = { at, zone, sub, level }, n, zones =
  { [zone] = n }, night = n, day = n, school = n }`.
- **Plants**: `plants[itemId] = { first = { at, zone, sub, level, how }, n,
  gathered = n, zones = { [zone] = n } }` (how: gathered, looted, other).

### How (game APIs, on both clients)

- **Fish**: `LOOT_READY` / `LOOT_OPENED` with `IsFishingLoot()`; the items
  from `GetLootSlotLink`; a school when the loot source is a game object
  (`GetLootSourceInfo`, a GameObject GUID) rather than open water. Day or night
  from `GetGameTime`.
- **Plants**: the herb items, by id, from the data; gathered when the loot
  source is an herb node (a GameObject GUID whose object is an herb in the
  data, or the Herb Gathering cast just before); else counted when one enters
  the bags (`CHAT_MSG_LOOT` self, `BAG_UPDATE` counts for bought or received).
- Forever: the same events; secret values checked as elsewhere.

### Data (scripts/flora.py, pinned CMaNGOS classic-db)

- **Fish**: `fishing_loot_template` by zone and subzone area, through its
  reference tables (11000 and up), with the seasonal ones (Winter Squid,
  Summer Bass) and the zone specials (Feralas Ahi, Misty Reed Mahi Mahi,
  Electropeller...); the items' names, icons and levels from `item_template`.
  Fish are the cooking-material and fish items those tables yield, junk left
  out.
- **Plants**: the herb items (item class Trade Goods, the herb subclass) and
  the herb nodes (`gameobject_template` gathered with Herbalism) with their
  spawns per zone (`gameobject`), and the skill each needs.
- Built into Data_Classic.lua and Data_Forever.lua beside the creatures.

### The book

As the Bestiary: on the left the species found, by kind (Plants: by the
Herbalism skill they need; Fish: freshwater, sea, special), search, fold; on
the right a species page: the item's icon in the round frame, the naturalist's
note, where it grows or bites (zones from the data), and the character's
record. A count in the header; no spoilers.

### Writing

`flora/*.md` and `fish/*.md` like the family notes: the naturalist's voice,
true to the original game, plain ASCII; then a review against sources
(Wowpedia, WoWWiki archive, the in-game texts).

### Steps

Step 1 done (6 October): data/flora.json, 30 herbs (Herbalism skill from the
client's Lock table, zones from the nodes' spawns, dungeons) and 39 fish
entries (19 food, 5 reagents, the Deviate Fish, 7 quest fish, 7 weighed kinds;
zones, subzones, dungeons, schools, the two seasonal ones). The database has
no hour for Nightfin and Sunscale: the catches record it. No Gromsblood in the
Blasted Lands in the database (to check with the notes).

Step 2 done (6 October): Flora.lua records catches (where, when, day or night,
school or open water, a weighed kind's heaviest) and herbs (gathered from a
node, looted, or found in the bags: bought, rewarded, mailed; those already
carried at login noted quietly), each new one announced in chat with a link.

Step 3 done (6 October): the Fish and Plants tabs (FloraBook.lua), between the
Bestiary and the Atlas (Bestiary, Fish, Plants, Atlas, Milestones): the kinds found in groups (fish: of the waters,
reagents, rare catches, quest fish, weighed catches; herbs by Herbalism rank),
counts, search; a kind's page (icon, where it bites or grows from the data,
the character's record), an overview per tab; the chat links open the pages.

Step 4 done (6 October): the Atlas's zone pages list what grows and bites
there (found ones named, the rest counted); milestones in two new groups,
Fishing (first catch, 10 and 20 kinds, every kind, 100 and 1000 fish, Nat
Pagle's four, a school of each kind, both seasons, Nightfin by night and
Sunscale by day, a catch of 100 pounds, every fish of each continent's waters)
and Herbs (first herb, 10 and 20 kinds, every herb, 100 and 1000 gathered,
Black Lotus, both lotuses, the Plaguelands' two, every herb of each of 37
zones, shown once one is found there).

Step 5 done (6 October): the naturalist's 69 notes (notes/herbs.md,
notes/fish.md: 30 herbs, 32 fish, 7 weighed kinds), reviewed against the data,
the game's own recipes and the Warcraft Wiki (11 corrections; Gromsblood's Blasted Lands added to the data; night counted from
6 PM). Next: release with the pending toast fix.

1. The data (scripts/flora.py): herbs and fish, their zones; counts checked.
2. The recording, with the simulation (fishing loot, schools, gathered vs
   looted herbs, bought ones).
3. The two tabs.
4. The Atlas lists and the milestones.
5. The notes (about 30 herbs, about 35 fish), then their review.
6. Release, with the pending fix (the achievement shield stand-in).

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
