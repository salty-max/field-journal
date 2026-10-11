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

## Expeditions (proposed 11 October 2026)

The user's idea: make players look at the world. Every zone has corners few
reach and things few notice: a grave beside a path, a statue nobody explains,
a book left on a shelf, a marker on a hill. The journal sends the reader to
them by riddles, and on the hunt for the quarries the lore tells of: a
book of expeditions, zone by zone. A solved riddle or a quarry brought down
is stamped with a seal and a picture of the moment.

### Decisions (11 October 2026, the user's)

| Question | Decision |
|---|---|
| Where | The Field Journal, both halves: the riddles (first planned in the Codex, moved here: they are about exploring the land, the journal's purpose) and the hunts. No sixth addon. |
| What the riddles target | The overlooked: props, graves, statues, plaques, books, peculiarities few players pay attention to; never a capital's front gate or a quest hub's obvious centre. Each holds a small story, true to the original game's lore. Only what the data pins down (below): a place nobody can locate for sure is no riddle. |
| Quality | Each riddle and poster thought through, one by one: fair, lore-true, worth the walk. |
| How many | By the land's size, from the game's data (below): a zone's riddles by the places its map reveals, three in each capital, one in each faction town of a contested zone for that faction alone; one quarry in every zone that has rares. |
| What the reader does | Varied, as the story calls for and never named: one of the client's emotes (kneel at a grave, mourn a fallen comrade, salute a hero, bow to kings, pray at a shrine, raise a toast at a brewery, sniff a suspicious barrel, peer across the water, sleep under the Dream's tree), a reading, the night; or simply being there. No gesture accepted by two riddles of a zone. |
| Hints | Rewarded when not used: seals and a margin only the unaided read. |
| The hunt's map | One quarry at a time is the target; only its haunts are shaded on the world map. |
| Achievements | Mandatory. |
| Pictures | Taken at the moment a riddle is solved (after its gesture, once the character is in it) and when a quarry is brought down; the postcards' technique, moved into the kit (`K.snapshot`) and shared with Hearthtale's postcards. |

### How many

From the client's own tables (wago.tools, Classic Era), so no number is
picked by hand:

- **A zone**: one riddle for every four places its map reveals as it is
  explored (its WorldMapOverlay entries), rounded up. The Barrens and
  Stranglethorn have 7, Ashenvale and Dun Morogh 5, Elwynn and Darkshore 3,
  Moonglade and Deadwind Pass 1. (The map rectangles' size was no measure:
  they count the sea.)
- **A capital**: three (a city reveals no places on its map).
- **A faction town in a contested zone**: one, for its own faction alone (a
  town: an innkeeper or a flight master serving one side only, from the
  dump; a town served for both sides is neutral, everyone's ground). Each
  side's riddle is its own: Astranaar's for the Alliance, Splintertree's for
  the Horde.

| | Eastern Kingdoms | Kalimdor | All (Classic) |
|---|---|---|---|
| Zones' riddles | **82** | **63** | **145** |
| Capitals' (three each) | 9 | 9 | 18 |
| Faction towns' (Alliance + Horde) | 11 + 8 | 9 + 11 | **20 + 19** |
| **Riddles in all** | | | **202** |
| **Quarries** (zones with rares) | **21** | **17** | **38** |

An Alliance reader has 163 (the 123 of the shared zones, the 11 of their
three starting zones, their capitals' 9 and their towns' 20), a Horde reader
162 (towns' 19). Up to level 30 (the first release): 68 zone riddles (46 in the twelve shared
zones, 11 in each side's three starting zones) and 17 town riddles (the
Alliance's 9: Thelsamar, Sentinel Hill, Auberdine, Lakeshire, Stonetalon
Peak, Astranaar, Menethil Harbor, Southshore, Darkshire; the Horde's 8: the
Sepulcher, the Crossroads, Camp Taurajo, Sun Rock Retreat, Splintertree Post,
Zoram'gar Outpost, Tarren Mill, Freewind Post): 85 in all, 66 for an Alliance
reader and 65 for a Horde one.

**Whose ground.** A zone's own riddles lie on ground both factions can walk:
never inside a faction's guarded town, neutral towns welcome (Booty Bay,
Gadgetzan, Ratchet, Everlook). A faction's town in a contested zone has its
own riddle, for that faction. The capitals' riddles are their own faction's
alone: an Alliance reader is never sent into Orgrimmar, nor a Horde reader
into Stormwind. The six starting zones are kept the same way (`home:` in
their files; confirmed by the user, 11 October): Elwynn, Dun Morogh and Teldrassil (reached only through
Auberdine's boat) for the Alliance, Durotar, Mulgore and Tirisfal for the
Horde.

A zone's riddles climb: **near the road** (passed every day, never looked
at), **off the road** (a detour worth making), **hidden** (remote, high, at the
end of something, or small enough to miss; never behind an exploit or off the
playable map); a zone of three or more has at least one of each. Deadwind Pass, Moonglade and Blackrock Mountain have no
rares, hence no quarry. Forever adds by the same rules: Zephras Isle's and its new zones' riddles
by their maps, its quarries, each capital it adds. The first release ships with
the riddles of every zone up to level 30 and their quarries; the full book is
the count above.

### The book (a sixth tab, Expeditions)

- **By zone**, shown once the zone is entered (as the Atlas's), and the
  reader's own faction's capitals: its riddles (near the road, off the road,
  hidden; its faction town's, for that faction) and its quarry. The zone is
  known; the place is the riddle. A zone's expedition is complete when its
  riddles are solved and its quarry brought down.
- The tab's select (`ns.filterOf`, as the Bestiary's): everything, riddles,
  hunts, unfinished.
- **A riddle**: its verse, its tier, its danger, whether it asks for a gesture
  or a reading, its two hints behind a question (below), and once solved its
  seal, the naturalist's note, the margin for the unaided, the picture's file
  name ("in your Screenshots folder: WoWScrnShot_101126_203501.jpg": an addon
  can't show a picture from that folder).
- **A quarry** (the board): its portrait, name, level, rank, the riddle of its
  haunts and habits, the naturalist's note, its danger, and the button that
  makes it the target. Quarries near you first: this continent, your level
  band (three below to five above), not yet brought down.

### Hints, seals and the margin

- **Two hints a riddle**, each asked for ("This riddle will no longer earn its
  gold seal"): a plainer clue in prose, then a circle shaded on the world map
  (wider than the spot, never centred on it). A riddle asking a gesture says
  so on its page ("asks something of you there"), never which: the verse
  never names it, the story leads to it; the first hint points closer
  ("Rejold's casks are not there to be looked at"), still without its name.
- **A quarry's help** is the target: its haunts shaded on the map (its spawn
  points from the pinned CMaNGOS spawns, clustered into a few soft circles;
  Forever's new rares from AllTheThings' coordinates), with a tooltip naming
  it. One target at a time, kept across sessions, nothing on the map for the
  others.
- **Seals**: gold, solved from the verse alone (a quarry: never made the
  target); silver, with the first clue; plain, with the map. A hint taken is
  kept even unsolved.
- **The margin**: every riddle and quarry has one more short paragraph of its
  story, true and sourced like the rest, that only a gold seal opens. A hint
  closes it for good.

### What solves a riddle (both games, outside combat)

| Condition | How |
|---|---|
| The place | The map and position (`C_Map.GetBestMapForUnit`, `GetPlayerMapPosition`; the Atlas reads them already), checked every second while in a riddle's zone, within a few yards of the spot. Open world only: Forever hides the position in its instances. |
| A gesture | The emote's token, by hooking `DoEmote` (`hooksecurefunc`, no taint), made at the place: any of the client's 256 (EmotesText: `KNEEL`, `MOURN`, `SALUTE`, `BOW`, `PRAY`, `TOAST`, `SNIFF`, `PEER`, `SLEEP`...). Every language: the token, never the text. The reader guesses it from the story, so a riddle accepts the few gestures that mean the same there (a fallen comrade: `MOURN`, `KNEEL`, `SALUTE`; the brewers' casks: `TOAST`, `DRINK`, `CHUG`), never one that doesn't; nothing tells a wrong guess from no guess. |
| A reading | A plaque, a tombstone or a book read there: the game's reader opening (`ITEM_TEXT_BEGIN`, its title from `ItemTextGetItem`) at the place. |
| The hour | At night (`GetGameTime`, the server's hour), only where the story asks for it. |

A quarry is brought down as the Bestiary already tells a kill (`PARTY_KILL`,
else the combat log's line); a trophy taken before the expeditions existed
stamps its poster quietly ("taken before the book").

**The answers stay unreadable**: the data holds no riddle's spot, only a
salted fingerprint (32-bit FNV-1a) of its map, its cell on a 2% grid and its
gesture or reading (one fingerprint for each gesture it accepts); the check fingerprints the player's cell and the eight
around it. The map hint's circle is stored plainly (it only shades a region).

### Danger

Each riddle and quarry says how dangerous its place is for its level, from the
pinned spawns within about 60 yards (their highest level, elites; a quarry's
own rank and level): "Quiet", "Guarded (to level 32)", "Perilous (elites)", and "the other
faction's land" in a zone it holds (its patrols on the roads). A Hardcore
character is never sent blind into an elite camp.

### What a character records

`FieldJournalChar.expeditions = { riddles = { [id] = { at, level, hints = 0..2,
shot } }, hunts = { [id] = { at, level, tracked, shot } }, target = id }`:
when, at what level, the seal (hints, or ever tracked), the picture's stamp
(`MMDDYY_HHMMSS`, at `SCREENSHOT_SUCCEEDED`).

### Content and the build

```
expeditions/<zone>.md                (one file a zone, named as the atlas's: its riddles, its quarry)
---
zone: 1431                           # the uiMap id
riddles:
  - id: duskwood-near
    tier: near
    reading: The Birth of the Lich King   # optional: a book or plaque read there
    gestures: [KNEEL, MOURN, PRAY]        # optional: the emotes' tokens it accepts, the story's own first
    night: false                          # optional
    object: 61                            # the spot: a game object of the dump, or
    area: Twilight Grove                  # a named sub-area of the game's, or
    where: { x: 0.0, y: 0.0, r: 2 }       # coordinates two sources agree on
    hint_area: { x: 0.0, y: 0.0, r: 8 }   # the map hint's circle
quarry: 522                          # its creature id (verified on Wowhead Classic)
client: both
---
## duskwood-near
(verse)
? (the first hint, prose)
= (the note, when solved)
+ (the margin, for the gold seal)
```

`scripts/build.ts` checks every field (the zone, the spot inside its zone, a
known gesture, the hint circle holding the spot, the quarry in
`data/creatures.json` and of the zone, plain ASCII), computes the danger from
the pinned spawns, and writes the fingerprints, never the spots, into
`Data_Classic.lua` and `Data_Forever.lua`; `scripts/hunt_spawns.py` (from
`rare_zones.py`) writes each quarry's haunts.

**The spots come from the game's data, not a character's walk** (the user has
no character that reaches everywhere), and only where the data pins them
down:

1. **A game object** (a grave, a plaque, a book, a statue the server spawns):
   its world position in the pinned CMaNGOS dump, placed on its zone's map by
   the client's UiMapAssignment, and the same spawn on Wowhead's page of the
   object (`wowhead.com/classic/object=<id>`: every copy, per map; the zone
   maps' rectangles overlap at their edges, and the history books stand in
   several inns); the two must agree within half a percent, or the build
   fails. Checked 11 October 2026 on the weathered grave (object 61): the
   dump gives Duskwood 17.7, 29.1, Wowhead Duskwood 17.7, 29.2. An object of
   a quest's that the game may show only during it is no spot.
2. **A named sub-area** (the game's AreaTable, as the Codex's
   `data/areas.json`: Duskwood alone has twenty, Twilight Grove, The World
   Tree, Addle's Stead...): solved on entering it (`GetSubZoneText`, by its
   id: every language). Its hint circle from the client's map overlay for it,
   or from something the data pins inside it: a creature that stands still
   (its spawn on both sources), a graveyard the server names
   (`world_safe_locs`: "Tirisfal Glades, Faol's Rest").
3. **A creature that stands still** (a prisoner, a keeper): its spawn, the
   dump's and Wowhead's alike; never one that walks a path. One an escort
   quest leads away now and then (Kaya Flathoof) is kept: finding the place
   empty is part of the riddle (the user's, 11 October).

No coordinates from a wiki or a guess: what the data can't place is not
written.

A `/journal where` (the map and position, as the Codex's `/codex where`)
remains for anyone to confirm a spot in passing; no riddle waits on it.

### Finding the riddles (the sources)

- **The game's own objects** (the pinned CMaNGOS dump, surveyed 11 October
  2026): 148 readable objects (plaques, tombstones, books on shelves) and 241
  named props (graves, monuments, statues, shrines, remains) placed in the
  41 zones: Terenas Menethil's grave by the Undercity, the Memorial to Sully
  Balloo, Grom's monument in Ashenvale, Eliza's tombstone in Duskwood,
  Trollbane's tomb in Arathi, the Hyal family's monument in Dustwallow,
  Yuriv's tombstone in Silverpine, an old lion statue in Redridge, the remains
  of Featherbeard, Kroshius and Sha'ni Proudtusk, the Armor of Mannoroth.
  Some are a quest's own (seen only during it): checked in the game.
- **What the database doesn't hold** (statues and wrecks that are part of the
  scenery): the wikis' hidden places and easter eggs, dated to the original
  game, and scouting in the game.
- **The quests' own words** (the same dump): a grave a quest names, a statue a
  giver explains, a story told in passing.

### Writing (the bar)

- The naturalist's voice for the notes and margins (the Bestiary's); the
  riddles in verse or plain lines, three to six, read aloud without a stumble;
  plain ASCII.
- Never name the answer. Every claim backed by the game's own texts (the
  object's words, its quest, its giver) or a source of the original game's era
  cited beside it in the file; no invented sights (colours, weather, what
  stands where) beyond what the game shows.
- Fair: the verse alone should lead an attentive player there; the first
  hint, a newcomer.
- A gesture or a reading only where the thing calls for it, and the one the
  story itself asks for, never named in the verse (no "kneel by him", no
  "smell the powder"): the story leads to it and the reader guesses it.
  It is what someone who knew the story would do there, as its own words
  suggest (kneel at a grave, mourn a fallen comrade,
  pray at an archbishop's resting place, raise a toast at a brewery, sniff
  the barrel of "strange smelling powder", hush where the dwarf says
  "Shhhh!"). Never a joke, a taunt or a flourish at someone's grief, never
  a gesture that only puns on a word of the verse; none rather than a forced
  one. Never a chore.
- Both factions: a riddle on hostile ground is kept, its danger saying so.

### Achievements (Milestones: Expeditions)

| Achievement | When |
|---|---|
| A Riddle Read Aright, First Quarry | the first riddle solved, the first quarry |
| (per zone) The Duskwood Expedition... | a zone's riddles (its faction town's for that faction) and its quarry; shown once the zone is entered |
| Near the Road, Off the Road, Nothing Hidden | every riddle of that tier on a continent |
| The Eastern Kingdoms, Kalimdor | every expedition of a continent |
| By Your Own Light, Clear Sight, Nothing Asked | 10, 50, every gold seal |
| Without a Map, No Trail Given | 5, every quarry brought down untracked |
| Respects Paid, Well Read, After Dark | every riddle asking a gesture, a reading, the night |
| Zephras Isle | Forever: the isle's expedition |

### The picture, in the kit (`K.snapshot`)

Shared by the expeditions and Hearthtale's postcards: `K.snapshot({ after =
seconds }, done)`.

- The interface made invisible (`UIParent:SetAlpha(0)`, put back as it was,
  never forced to 1), the minimap as the postcards' last test decides (`/pct
  4`, `/pct 5`, still owed), the shot (`Screenshot()`) from a timer, the
  opacity back at `SCREENSHOT_SUCCEEDED`/`FAILED` or after two seconds.
  Tested on 10 October: in and out of combat, a vendor's window stays open.
- Never in combat (queued to `PLAYER_REGEN_ENABLED` plus a second, dropped
  after 20 seconds or a change of zone), never over a loading screen or a
  cinematic; the interface already hidden (Alt+Z): the shot alone. One at a
  time across the family: an interface already at opacity 0 waits its turn.
- Quiet: the game's "Screen captured" silenced; `done(stamp)` gets the file's
  stamp. Nothing of the game's settings touched. A setting: pictures on (the
  default, as the user wants them) or off.

### The model zone: Duskwood (written in full; spots from the data)

Duskwood, levels 18 to 30: the first three of its four riddles and its
quarry, on ground both factions walk (the fourth, and Darkshire's for the
Alliance, are in `expeditions/duskwood.md`). Facts from the
pinned dump (objects 37 and 61, quests 225, 228, 253), the game's sub-areas
and the Codex's checked pages (`the-embalmer`, `morladim`, `raven-hill`,
`dragons-of-nightmare`).

1. **Near the road: Twilight Grove** (`area: Twilight Grove`, the forest's
   heart, the road running past it; codex page `dragons-of-nightmare` for the
   lore). Danger: Quiet, Perilous when a dragon of the Nightmare is there (a
   world boss, at times).

   > In the heart of the dark wood a great tree stands apart:
   > a door the dreaming druids walk through to the Emerald Dream.
   > Green dragons were set to keep it; the Nightmare took the keepers.
   > The door opens for those who go the druids' way.

   Hint: "The road through the forest bends around something older than the
   town." Note: "One of four such trees in the world, the green dragonflight's
   doors into the Emerald Dream. Its guardians came back from the Dream
   changed." Margin: (Remulos's gathering of the Nightmare's traces from the
   four portals, and what the druids fear of them).

2. **Off the road: Eliza's tombstone** (`reading: Eliza's Tombstone`, by the
   Embalmer's shack above Raven Hill; the dump: 28.9, 30.5). Danger: Guarded
   (Raven Hill's dead).

   > A kindly man of potions lost his wife,
   > and would not let her go; he gave her his own heart.
   > It woke her hungry, so he keeps her in the earth
   > above the hill of ravens, under a stone with a few kind words.

   Hint: "An old hermit's shack overlooks the graves of Raven Hill; he did
   not come alone." Note: "'Beloved wife, may the earth sate your hunger.'
   (the stone's own words, object 37). The Embalmer meant it kindly, I think,
   which is the worst of it." Margin: (the
   children's story Darkshire tells of him, and what the Night Watch found:
   quest 253).

3. **Hidden: the weathered grave** (`gestures: [KNEEL, MOURN, PRAY]`, Morgan Ladimore's
   marker, "out past the house on the hill", outside the cemetery's ground).
   Danger: Guarded; Mor'Ladim himself wanders near (an elite).

   > He came home from the plague to a grave on the hill,
   > and grief made a killer of a good man's will.
   > They buried him quickly, past the house on the rise,
   > outside the hallowed ground, where nobody grieves for him.

   Hint: "Not every grave of Raven Hill lies inside its walls." Note: "The
   marker says only MORGAN LADIMORE. The earth over it has been disturbed:
   he did not stay." Margin: (the name worn down to the one the forest knows,
   Mor'Ladim; his daughter Sarah in the Night Watch, and her message to him).

**Duskwood's quarry: Mor'Ladim** (522; elite, level 35; a named wanderer:
Duskwood's rares are researched in the pass below, and the lore's own story
here is his; quest 228).

   > The forest calls him by half a name,
   > the rest worn off like letters from a stone.
   > He walks among the graves of the hill he came home to,
   > and kills whoever he meets. Find the stone, and you will know him.

   Note: "Not a beast, and no rare in the Bestiary's sense. The Night Watch
   wants him laid to rest, and his daughter serves in it. Go with company."
   The poster and the hidden riddle lead to each other: the poster sends the
   reader to the grave; the grave's name (MORGAN LADIMORE, worn to Mor'Ladim)
   tells who is hunted, the grave's gold margin saying it outright.

Two more posters written, for their zones' expeditions: **Timber** (Dun
Morogh, 1132, rare 10: "The hunters of Kharanos set their snares, and he
walks round; / he doubles on his own trail, and he picks his own ground. / Of
all the wolves that run in the snow of the vale, / he is the one larger than
the rest, who will not take the bait.") and **Ghost Howl** (Mulgore, 3056,
rare 12, quest 770: "A wolf runs the plains with a wound on his hide / that no
beast of the grassland ever gave him. / The Legion marked him. At Bloodhoof, a
hunter / would know the hide, and wish its spirit peace.").

### Steps

1. The picture: the postcards' minimap test (`/pct 4`, `/pct 5`), then
   `K.snapshot` in the kit, synced to the journal (and to Hearthtale for its
   postcards).
2. The data: `expeditions/` (beside `atlas/`: `content/` holds the Bestiary's
   sections), the build's checks, the spots (objects
   placed and checked against Wowhead, sub-areas, agreed coordinates), the
   fingerprints, the danger, `hunt_spawns.py`; `/journal where`; the test game learns
   `DoEmote`, the reader's title, `Screenshot` and the map's target layer.
3. The engine: `Expeditions.lua` (the place each second in a riddle's zone,
   the gesture hook, the reading, the hour, the kill; solved, recorded, the
   seal, the alert, the picture), the target's map layer (the world map's
   data provider, as `WorldMapPins.lua`).
4. The tab (`ExpeditionsBook.lua`): zones once entered, their riddles and
   quarry, hints asked for, seals, notes, margins, pictures; the achievements.
5. The writing, zone by zone, Duskwood first: candidates from the sources
   above, each spot from the data (an object, a sub-area, two sources), a
   first release with every zone up to level 30; then the rest of the 141 and
   the 38. Written on 11 and 12 October 2026 (`expeditions/`, a file a zone
   or capital, named as the atlas's): all 202 riddles, each with its sources
   and where the data pins it (no estimate left), and Duskwood's quarry. The
   other quarries come with the hunts' pass.

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
