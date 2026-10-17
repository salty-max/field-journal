# Yonder (Explorer's Field Journal until 0.8.0)

> Renamed on 13 October 2026: Field Journal: Forever ships the same
> `FieldJournal` folder. The plan below keeps its old names where it records
> what was decided then (`FieldJournalChar` is `YonderChar` now, `/journal`
> is `/yonder`).

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
| What the riddles target | The overlooked: props, graves, statues, plaques, books, peculiarities few players pay attention to; never a capital's front gate or a quest hub's obvious centre, with a distinct experience even at a quest location (17 October, below). Each holds a small story, true to the original game's lore. Only what the data pins down (below): a place nobody can locate for sure is no riddle. |
| Quality | Each riddle and poster thought through, one by one: fair, lore-true, worth the walk. |
| How many | By the land's size, from the game's data (below): a zone's riddles by the places its map reveals, three in each capital, one in each faction town of a contested zone for that faction alone; one quarry in every zone that has rares. |
| What the reader does | Varied, as the story calls for and never named: one of the client's emotes (kneel at a grave, mourn a fallen comrade, salute a hero, bow to kings, pray at a shrine, raise a toast at a brewery, sniff a suspicious barrel, peer across the water, sleep under the Dream's tree), a reading, the night; or simply being there. A riddle accepts every gesture that means the same there, whatever its neighbours accept (12 October). |
| Hints | Rewarded when not used: seals and a margin only the unaided read. |
| The hunt's map | One quarry at a time is the target; only its haunts are shaded on the world map. |
| Achievements | Mandatory. |
| Pictures | Taken at the moment a riddle is solved (after its gesture, once the character is in it) and when a quarry is brought down; the postcards' technique, moved into the kit (`K.snapshot`) and shared with Hearthtale's postcards. |

### Reworked (12 October 2026, the user's)

A review of the 202 (by another model) found factual slips, too many riddles
solved by arriving, and too many famous leaders; the user added: riddles and
quarries are never tied to quests, or they are too obvious; don't rely on
quest texts alone; search the web; cross-media lore is welcome when it is not
anachronic to the original game or Forever. Every zone and capital rewritten:

- **Quest locations may hold a separate discovery** (updated by the user,
  17 October). A familiar location is allowed when Yonder asks for a different
  action or highlights an overlooked detail. Do not repackage a quest objective,
  require its item, depend on a temporary quest prop, or invent extra history.
  Class-quest locations remain eligible. Quarries remain rares, never a quest's
  kill target. A reviewed overlap is recorded as exact `quest_overlap` ids and
  a `quest_context` explaining what the riddle adds.
- **Sources** beyond the quests: the dump's props, inscriptions, gossip and
  scripted lines (broadcast texts), the WoWWiki archive (its later
  expansions' lines set aside), Warcraft III, Lands of Conflict, the Warcraft
  RPG, Chronicle for the old past, the client's display tables (who a keeper
  is), and the data's own oddities (a fang that drops as a dagger, a
  night-only ghoul).
- **The note delivers a discovery**: what the world says once you are there
  (the riddles' own notes, in `expeditions/`).
- **Fewer when the land has nothing untied to show**: a zone keeps one riddle
  or none, a faction town loses its riddle. A keeper who walks is found by
  targeting, placed by the path that crosses the hint circle.
- **Counts after it**: 117 riddles (59 for both sides, 31 the Alliance's, 27
  the Horde's: 90 for an Alliance reader, 86 for a Horde one) and the 38
  quarries, every one a rare no quest names.

### After the first test in the game (12 October 2026, the user's)

Dun Morogh played through: Misty Pine Refuge solved from a flight overhead;
two of its five riddles only "go there", two meant a kill (Gibblewilt, and
Ironband's Dark Irons); the two places are now Forever's quests' roads; the
riddle's own alert lost behind the trophy's; the book's pages bare. So:

- **Never from a taxi, nor as a ghost**, and never in combat, as before.
- **Never a kill**: a creature a riddle asks for is no foe of the side that
  may solve it; one that attacks the other side is its own side's riddle
  (`faction:`, now on any tier; which riddles, in `expeditions/`: not
  repeated here, for the players' sake).
- **Never the same discovery twice in a zone.** Different places may share
  an arrival, a reading, a conversation or a gesture. Do not make up an
  emote merely because another riddle already uses the natural one. Each
  riddle needs its own subject and observation. The resolver rejects reused
  subjects (including a group's companion keepers) and overlapping passive
  arrival footprints, rather than limiting each action to one per zone.
- **Review Forever quest overlaps**: the resolver flags new quests that
  give, end or ask for a riddle's subject, name it, or send players within 4%
  of a passive arrival. An explicit `quest_overlap` list with a `quest_context`
  can acknowledge a separate experience. Only the named quest ids are exempt,
  so future quest changes still surface. Passing the resolver does not replace
  editorial review of the action and note.
- The resolver checks these safeguards (`scripts/expeditions.py`), and the build
  refuses what fails.

Several zones' riddles were replaced where a city or a land asked one deed
twice, some turned into gestures, and a few dropped with nothing untied to
put in their place. Which ones is in `expeditions/`, not repeated here, so
the plan gives no answer away.
**106 riddles** (47 both sides', 32 the Alliance's, 27 the Horde's: 79 for an
Alliance reader, 74 for a Horde one; 62 gestures, 23 readings, 17 keepers
found by speaking, 8 arrivals), Zephras Isle's four and the 39 quarries.

The book after it: a toast for each riddle and quarry, queued beside a
milestone's (`Toasts.lua`); the zone's page in words, a card for each riddle
and its quarry, its map (the Atlas's, now shared: `ZoneMap.lua`) with where
each was read, the places asked for and the haunts tracked; the verse set
apart, the seal earned, the note and the margin in their own blocks; the
quarry turning in its frame on its poster; a riddle or quarry pinned to the
screen (`ExpeditionsPin.lua`: a card to drag anywhere, closed by its cross).

**Forever's own (12 October 2026).** Zephras Isle, the only new zone with
data while the beta caps the others: four riddles by its 19 map places, none
a quest's (the Wowhead Forever zone listing's quests, the QuestieDB traces'
starters, enders and objectives) (which, in `expeditions/zephras-isle.md`); the quarry the Lost One, the isle's only dragonkin, an
elite of level six by Windsong Lake, a creature the data doesn't know (its
name, level, rank and model in the file). Placed from the QuestieDB traces
(commit 7e87203) where Wowhead's Forever database agrees, on Forever's
client tables (build 1.60.1.70291); the texts from warcraft.wiki.gg's pages
and Wowhead's quotes. The book files the isle under Elsewhere, as the Atlas
does; its expedition is a milestone of its own. The other new zones
(Riverglades, Shen'dralas, Hyjal, Gilneas) wait for the launch.

The follow-up prose pass keeps those counts. Book clues now single out a
detail instead of reciting the whole history; quarry notes trade exact
respawn promises for appearance, behaviour, routes and history. Two riddles' gestures and one
discovery's source were corrected. Corrections,
sources and the remaining in-game question: the expeditions review, kept
outside the repository (it gives the answers away).

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
| **Quarries** (zones with rares, not capitals) | **21** | **17** | **38** |

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
  so on its page ("an emote there"), with proximity and targeting explained
  for a creature. The page never names the emote: the verse leaves it to
  the story. The paid clue helps with both the place and the action, and
  may name one accepted gesture in ordinary words. It need not list the
  alternatives. Keep it in the League's voice, with the general mechanics
  on the page rather than repeated in each clue.
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
| The place | The map and position (`C_Map.GetBestMapForUnit`, `GetPlayerMapPosition`; the Atlas reads them already), checked every second while in a riddle's zone, within ten yards of the spot (a keeper's wandering added). A sub-area by its name (`GetSubZoneText`, matched to the zone's area ids through `C_Map.GetAreaInfo`: every language). A keeper also by targeting them near (`CheckInteractDistance`, 11 yards): the only way to a keeper who walks a path (Kum'isha, Falfindel). Open world only: Forever hides the position in its instances. |
| A gesture | The emote's token, by hooking `C_ChatInfo.PerformEmote` (`hooksecurefunc`, no taint: the chat's `/kneel` and the emote menu call it on both clients, as their deprecated `DoEmote` does; Blizzard's UI source, checked 12 October 2026), made at the place: any of the client's 256 (EmotesText: `KNEEL`, `MOURN`, `SALUTE`, `BOW`, `PRAY`, `TOAST`, `SNIFF`, `PEER`, `SLEEP`...). Every language: the token, never the text. The reader guesses it from the story, so a riddle accepts the few gestures that mean the same there (grief at a grave, say, or cheer at a feast: each a few tokens), never one that doesn't; nothing tells a wrong guess from no guess. |
| A reading | A plaque, a tombstone or a book read there: the game's reader opening (`ITEM_TEXT_BEGIN`) at the place. Every reading is a text object of the game's (type 9, its name the reading's title: the data script checks), which opens the reader; a quest's poster would open the quest window instead. |
| The hour | At night (`GetGameTime`, the server's hour), only where the story asks for it. |

A quarry is brought down as the Bestiary already tells a kill (`PARTY_KILL`,
else the combat log's line); a trophy taken before the expeditions existed
stamps its poster quietly ("taken before the book").

**The answers stay unreadable**: the data holds no riddle's spot, only
salted fingerprints (32-bit FNV-1a) of the riddle with each 5-yard cell
within reach of its spot (the zone's size in yards from the client's
UiMapAssignment), with its sub-area's id, with its keeper's creature id, and
with each gesture it accepts; the check fingerprints the reader's own cell,
sub-area, target and gesture. What is read once it is solved (the answer's
name, the note, the margin) is veiled by a stream from the riddle's id. The
map hint's circle is stored plainly (it only shades a region). (The repo's
`expeditions/` files are public: this keeps the answers out of the addon's
files, no more.)

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
    reading: <a book's title>             # optional: a book or plaque read there
    gestures: [EMOTE, ...]                # optional: the emotes' tokens it accepts, the story's own first
    companions: [CREATURE_ID, ...]        # optional: other members of a gesture's group that count as targets
    night: false                          # optional
    object: <id>                          # the spot: a game object of the dump, or
    area: <a sub-area>                    # a named sub-area of the game's, or
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
  hint, a newcomer. If solving also needs an action, the verse must suggest
  that action, and the paid hint must help with it as well as the location.
  The hint may name an ordinary action, without giving a slash command or
  listing every accepted emote. General targeting instructions belong on
  the page. The verse keeps its inference and its own voice.
  Do not make a player spend a seal to learn only a place they already found.
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

Duskwood, levels 18 to 30: the model zone, written in full first. Its
riddles, their verses, hints, notes and answers, are in
`expeditions/duskwood.md` and not repeated here, so the plan gives none of
them away. Its quarry, whose poster names it in the game anyway:

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

   Built for the riddles on 12 October 2026: `scripts/expeditions.py`
   (`data/expeditions.json`: every spot from the game's data; an object's
   spawns kept where the dump and Wowhead agree and inside the hint circle,
   a history book's copies in other inns being other riddles'; a keeper's
   walk measured from the dump's paths), `scripts/expeditions.ts` (the
   build's checks and the fingerprints), `Expeditions.lua`,
   `ExpeditionsBook.lua` (a sixth tab before the Milestones), the map's
   circle (`Media/Circle.tga`, on the world map's data provider), the
   milestones (A Riddle Read Aright, each zone's expedition, the roads, the
   byways and nothing hidden of each continent, every riddle of a continent,
   the gold seals, Respects Paid, Well Read, After Dark) and `/journal where`;
   the simulation solves Duskwood's five and two others.

   The hunts, the same day: the 38 quarries written (one a zone with rares;
   the capitals have none, Stormwind's Sewer Beast staying the Bestiary's),
   each the foe its own quests tell of: a wanted poster, a giver's grief or
   grudge (Hogger, Old Murk-Eye, Mangeclaw beside the pilot it killed,
   Lakota'mani, Thule Ravenclaw, Krom'Grul, Gammerita, Araj the Summoner...);
   never one the game makes unkillable without a quest's item (the Defiler's
   triad) or summons, nor one a riddle's margin already tells (Hetaera); in
   Hillsbrad and the Blasted Lands, whose quests tell of none, a rare, its
   poster only what the data shows (the strand, its neighbours, its
   seldomness). Their haunts from the data script (spawns that Wowhead
   places within 2%: it records sightings of a creature that moves; a path
   walked gathered into circles along it: Twilight Marauder Morna's road is
   seven). The engine: the kill as the Bestiary tells it, the target and its
   haunts on the world map (tracking asked through the game's confirmation,
   the gold seal lost for good), kills from before the journal kept the hunts
   stamped quietly at the login with no seal, each zone's expedition its
   riddles and its quarry, First Quarry, Without a Map, No Trail Given. Still
   to do: the pictures (`K.snapshot`), a test
   in the game.
5. The writing, zone by zone, Duskwood first: candidates from the sources
   above, each spot from the data (an object, a sub-area, two sources), a
   first release with every zone up to level 30; then the rest of the 141 and
   the 38. Written on 11 and 12 October 2026 (`expeditions/`, a file a zone
   or capital, named as the atlas's): all 202 riddles, each with its sources
   and where the data pins it (no estimate left), and Duskwood's quarry. The
   other quarries come with the hunts' pass.
   Reworked the same night (above): 117 riddles and 38 quarries, none a quest's;
   after the first test in the game, 106 (above).

## Decisions (5 October 2026)

| Question | Decision |
|---|---|
| Shape | One addon, two books (Bestiary, Atlas). |
| Games | Classic Era / Hardcore / SoD, TBC Anniversary, Forever. |
| Voice | A naturalist of the Explorers' League (the Codex's world): a short note per family; the numbers come from play. |
| First | The Bestiary; the Atlas follows and reuses its position records. |
| Entries | A page per family (wolves, kobolds, the Defias…), listing every creature met in it with its own record. |
| Coverage | Beasts and monsters, humanoid peoples, rares and bosses (as trophies). Not critters or friendly NPCs. |
| Name | Yonder since 13 October 2026 (Explorer's Field Journal before; repository `salty-max/field-journal`). |

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

## Finds: one tab for the collections (planned 16 October 2026)

The user's update to the professions idea (`../ideas/professions.md`): adding
Ores & Gems and Cloth & Leather as more top-level tabs would crowd the book.
Bring them together with Fish and Plants in one **Finds** tab instead.
This is planned work, not part of the current release. The Fish and Plants
section below records the existing implementation.

### Decisions

- **One book tab: Finds.** It replaces the current Fish and Plants tabs.
  Fish, Plants, Ores & Gems, and Cloth & Leather are navigation groups inside
  it, not additional top-level tabs. Expeditions, Bestiary, Atlas and
  Achievements keep their own places.
- **Profession unlocks by family.** Fish needs Fishing, plants need
  Herbalism, ores, stones and gems need Mining, and leather and hides need
  Skinning. Learning the profession unlocks the corresponding family.
- **Tell the player when a family unlocks.** Show a banner and a clickable
  chat message naming the newly available category, with a click opening
  that group in Finds. This announces the category, not an achievement or
  an individual item discovery. Keep the unlock notification per character
  so it does not repeat on login, reload, profession rank changes or
  relearning a profession whose category was already announced. Translate
  the notification with the rest of the interface.
- **Cloth is open to everyone.** The user explicitly chose no Tailoring
  requirement. Cloth and leather may share a navigation group, but the
  cloth collection must not be hidden behind Skinning.
- **Discovery still matters.** A profession opens its family, not every
  item page within it. Keep the current approach of pages discovered from
  finds and no catalogue of undiscovered item names.
- **The book keeps what it learned.** The user explicitly chose to keep
  discovered pages readable after dropping a profession. Never discard the
  collection's records, counts or earned achievements when a skill is
  unlearned. Migration must also preserve existing fish and herb pages for
  characters who do not currently have the relevant profession.
- **Keep recording after unlearning.** Once a family is unlocked, newly
  obtained items can still open its pages even if the character drops the
  profession. An unlock is permanent for that character.

### Content and data

- Data readiness was audited on 16 October 2026 against the current
  published wow-data snapshot. See
  [the audit](docs/finds-data-readiness-2026-10-16.md) and
  `scripts/finds-audit.py`. The original-world baseline can proceed. Some
  Forever nodes and materials need more source evidence before inclusion.
- Keep the existing fish and plant records, notes and item identities.
- Add ores, the stones and gems found with them, cloth, leather and hides.
  Collection entries are the material items themselves, keyed by item id.
  Mining nodes never get Finds pages or separate collection progress:
  Small and Rich Thorium Veins both supply the same Thorium Ore page.
  Nodes are source metadata only, for locations and gathering detection.
- **A distinct naturalist's note for every new item.** Every ore, stone,
  gem, cloth, leather and hide entry needs its own authored note, just as
  every fish and plant does. Gems must not share a generic group note.
  Translate these notes with the existing content and require a note for
  every included item in the build. Each page also keeps the character's
  own finds, as the existing Plants and Fish pages do.
- Review the English notes for the established naturalist's voice before
  translating them. Keep the observations, source discipline and dry
  humour of the fish and herb notes in every language.
- Mining nodes and required skill come from wow-data's objects and client
  Lock table. Their loot supplies the ores, stones and gems, and their
  spawns supply the locations. Creature loot and skinning loot supply cloth
  and leather sources. Establish the exact item lists from the data before
  writing notes or setting completion totals.
- Record finds by item id. Distinguish gathering from other ways of
  obtaining an item, as Plants already does. Receiving an ore or leather in
  the bags does not prove that the character mined or skinned it.
- Keep Atlas links and achievement progress consistent with the new
  collections. Existing fish and herb links must still open their pages
  after the navigation changes.
- Cover both game clients and the existing translated interfaces.

### Implementation questions still open

- The navigation inside Finds: grouped list, category selector or overview
  cards. The single top-level tab and profession rules are decided.
- The overview and achievement totals for families the character has not
  unlocked. Do not turn professions the character lacks into apparent
  missing progress.
- How to present the categories already available on the first upgrade to
  Finds, including universally available cloth and professions already
  learned. Make the new navigation discoverable without replaying unlock
  banners at every login.

## Fish and Plants (existing implementation)

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
