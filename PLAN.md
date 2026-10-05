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

Places visited (first visit: date, level), the roads walked (positions
sampled every few seconds, kept light), flight paths taken, deaths and close
calls, drawn on the world map with the game's own map art. Details planned
once the Bestiary ships.

## Engineering (from the Codex)

- Content in Markdown (`content/families/<id>.md`: note, front matter with
  type, beast family or id lists), built to Lua by `scripts/build.ts`, one
  content file per game; `scripts/package.ts`, release script, CI, CurseForge
  workflow and the simulation (`luajit addon/test/sim.lua`, Classic and
  Forever modes) copied from the Codex.
- Forever: no combat log, secret values checked (`issecretvalue`), modern API
  fallbacks.
- Logo in the Codex's style.

## First steps

1. Repository from the Codex's skeleton (build, package, release, CI,
   simulation), empty content.
2. The recording engine (meet, slay, loot, trophies), with the simulation.
3. The family data: the CMaNGOS creature list sorted into families, the
   Codex's peoples, the boss lists.
4. The book (family list, family page, search, tooltip).
5. The notes, family by family, then review; release 0.1.0.
