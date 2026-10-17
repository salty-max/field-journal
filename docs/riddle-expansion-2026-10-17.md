# Riddle expansion and hidden-place inventory

Research and local implementation: 17 October 2026. Nothing pushed or released.
The frozen position additions are in local wow-data commit `d8d1cfe`.
That data commit must precede Yonder when these changes are eventually pushed.

Refined after the user's request for more Teldrassil discoveries, including
Dolanaar. The user then confirmed **six total** for the second batch, including
the two Dolanaar proposals. Five are now implemented with French, German and
Spanish text. The Stonetalon logging camp remains a
[working draft](stonetalon-logging-camp-draft-2026-10-17.md), held for its route
and a verified landmark. It is not included in the book or completion totals.
The first batch below remains included. Nothing has been released.

## Second batch: implementation status

| Requested discovery | Status | What the implementation checks |
| --- | --- | --- |
| Keldamyr's invitation | Implemented | Sleeping or lying down, within ten yards of the innkeeper's fixed position and indoors. No target, quest, purchase or wait |
| Dolanaar's Ancient Protector | Implemented | Nearby protector targeted and player inside the selected Dolanaar patrol corridor. A matching NPC near Darnassus cannot substitute |
| Dun Morogh abandoned camp | Implemented for testing | The user confirms the camp lies just metres south of the corroborated bear spawn. A ten-yard fixed arrival footprint includes that vicinity, without needing a bear alive or targeted. The mortar radius is tightened from 75 to 70 yards, keeping all tested range positions. A regression check verifies that the two discoveries share no five-yard cell. Check the camp's exact southern edge in game |
| Badlands crypt | Implemented | Arrival near Sword of the Barbarian King, object 144181, inside the crypt. Questie and the Classic world spawn agree at 57.25, 40.03. Outdoor ground below does not count |
| Arathi coastal farm | Implemented | Arrival near the stable's stationary ram spawn positions, corroborated independently by Questie. The rams need not be alive or present. Both factions can discover the place, with the danger line warning Horde visitors about the farmers |
| Stonetalon logging camp | Draft, not enabled | No verified mill-yard footprint in wow-data. The retrievable access descriptions involve climbing roofs or crossing an invisible wall. An approximate destination and a sightseeing video are insufficient for a production arrival answer |

The book now contains **119 Forever riddles and 115 Classic riddles**.
Teldrassil has **four**. The six requested additions would make 120 and 116
only if Stonetalon proves suitable. No substitute has been silently added.

The new authoring support is deliberately narrow: `found: patrol` requires
both target and location, `found: place` permits an arrival at a fixed anchor,
and `indoors: true` asks the client to confirm the interior. Independent
Questie checks are now also available for Classic creature anchors when
Wowhead's tooltip only returns another zone. These remain community world
records, not a claim of live confirmation on Forever.

## Decisions

The user permits a distinct experience at a quest location. A moonwell visited
for a water sample can also invite a drinking gesture. Repeating a quest's
objective, requiring its item, or relying on its temporary props is still out.
Exact reviewed quest ids and a reason are recorded in the authored source.
New unreviewed Forever quest overlaps still fail the resolver.

Different discoveries can share the natural action. The old one-reading,
one-conversation and one-arrival quotas encouraged arbitrary emotes and left
some zones thin. Reused subjects and overlapping passive arrival footprints
remain rejected. No changes to the live solving rules or the book's appearance.

## First additions

| Zone | Before | After | Discovery and evidence |
| --- | ---: | ---: | --- |
| Teldrassil | 0 | 2 | Shadowglen Moonwell drinking gesture, and Nadyia's hospitality |
| Darkshore | 1 | 2 | The Auberdine copy of Mount Hyjal and Illidan's Gift |
| Moonglade | 1 | 2 | Give the Great Bear Spirit an attentive ear |

After this first batch, the totals were 114 Forever riddles and 110 Classic
riddles. The second-batch status above gives the current counts. All starting
zones now have at least two authored riddles for their home faction. This is
a first batch, not a claim that every zone now offers equal coverage. Darkshore's
two entries remain Alliance-only. Moonglade's are available to both factions.

Each addition has an English verse, paid hint, solved note and gold margin,
with French, German and Spanish translations. Mexican Spanish shares the
Spanish prose with its own game names. No new English wordplay is required.

### Shadowglen Moonwell

Object 19549, Classic world spawn projecting to 59.946, 33.050. Questie independently
places it at 59.95, 33.05 in both games, agreeing with the user's 59.9, 33.1.
Wowhead's fetched tooltip supplies no map coordinates for this object. The source
therefore explicitly selects Questie as the independent position check, with
the usual 0.6 percentage-point agreement tolerance. It does not invent a
Wowhead sighting, use player observer coordinates, or broaden the location to
all of Shadowglen. The existing ten-yard object footprint remains in use.

Accepted gestures are DRINK and THIRSTY, the actual client tokens. No target,
quest, drink item or vial is required. The hint spells out the distinction.
Crown of the Earth (921) explicitly requests a phial, so this overlap is
acknowledged. Tenaron's quest text supports the solved note about moonwell
water and Elune. Mooncloth spell 18560 supports the tailoring margin. The
riddle does not promise healing or a drinkable world-object interaction.

### Nadyia Maneweaver

Creature 3605, Classic spawn near 41.9, 49.4, frozen Wowhead points 41.8,
49.4-49.6. This restores the earlier hospitality concept under the user's
revised policy. Forever quest 97946 ends at Nadyia, but the riddle thanks her
for welcoming visitors and needs no profession or quest. It names her rather
than implying Radnaal must also accept the gesture.

Her welcome is reported firsthand in the [Classic NPC comments](https://www.wowhead.com/classic/npc=3605#comments).
The [gossip transcription](https://warcraft.wiki.gg/wiki/Nadyia_Maneweaver)
distinguishes the ordinary welcome from advice shown to leatherworking
students. The advice about stitches, quivers and lumpy tunics belongs in the
margin, not as a requirement for an untrained player to see that dialogue.

### Auberdine's book

Readable object 175729, type 9. Classic spawn 36.56, 44.03, independently
corroborated by Wowhead at 36.6, 44.0. The database holds all eight English
pages and localized titles and text. The note stays within the book's account
of Illidan recreating the Well, his brother's objection, and imprisonment.

### Great Bear Spirit

Creature 11956, Classic spawn independently corroborated by frozen Wowhead
points around 39.2-39.6, 27.4-27.6. Client faction 35 is friendly. The
ordinary greeting is broadcast text 7438. Lessons 7441, 7443 and 7445 describe
body and heart. Class quests 5929 and 5930 acknowledge the teaching context.
Yonder needs only the LISTEN gesture, not the quest dialogue sequence, class
training or Bear Form. The hint distinguishes the gesture from a quest step.

## Inventories found on the web

These are candidate-finding aids. An inventory's label of "Classic" does not
prove that its route works in Forever or that the feature is persistent.
No video walkthrough has been substituted for an in-game playtest.

- [Madburst's five Classic locations](https://www.warcraftmovies.com/movieview.php?id=252884),
  published 11 April 2020. The author's index identifies Badlands Crypt at
  00:47, Shatterspear Troll Village at 01:37, Stonetalon Logging Camp at 02:34,
  Tanaris Underwater Village at 03:33, and Secret Stranglethorn Cave at 04:40.
  This is useful firsthand exploration material with a precise itinerary.
- [WoW Classic Exploration Guide - 50+ Hidden Spots](https://www.youtube.com/watch?v=r2P0OqqGCxo).
  Found through the search index. The full video description and routes were
  not retrievable in this session, so the advertised count is not treated as
  50 validated candidates.
- [All Secret Locations of World of Warcraft: Classic](https://www.youtube.com/watch?v=ziq8_5zEP6k).
  Another indexed exploration inventory. Full route review still pending.
- [Lost WoW](https://lostwow.com/). Its catalogue covers the airport, Wetlands
  farm, Shatterspear, Newman's Landing, Tanaris islands and closed areas.
  Good for leads, with mixed game eras and many inaccessible sites.
- [Players' Secret Places thread](https://us.forums.blizzard.com/en/wow/t/secret-places/157865).
  Includes firsthand memories of the Arathi coastal dwarf camp, southern
  Kalimdor tauren camp and Badlands crypt. Also includes glitch-only places,
  so the thread is not an accessibility guarantee.
- [Firsthand Badlands crypt discovery](https://www.reddit.com/r/classicwow/comments/1gawugg/cool_crypt_in_badlands/),
  posted by a Hardcore player in October 2024, with a screenshot and report
  of a seated, armoured skeleton. Other commenters interpret it as a Conan
  reference. That interpretation is not in-world history for a solved note.

[Warcraft Tavern's Exploration Guide](https://www.warcrafttavern.com/wow-classic/guides/exploration/)
is a travel overview, not the hidden-place inventory its title might suggest.

## Refined list for the next additions

These are the six shared-world subjects selected by the user. Their current
implementation status is above. A strong concept does not replace a verified solution
location, an ordinary route or an in-game check in each supported game.

| Zone | Proposed discovery | What the player would do | Why keep it | Remaining work |
| --- | --- | --- | --- | --- |
| Teldrassil | Keldamyr's invitation to rest, Dolanaar | Rest with a sleeping or lying-down gesture inside his inn, without a target | An accessible third Teldrassil riddle. His invitation gives the action a reason beyond visiting an inn | Check the ten-yard interior footprint and ordinary welcome on both clients. Quest overlap 2159 is recorded |
| Teldrassil | Dolanaar's walking Ancient Protector | Pay respect to the living guard, accepting salute, bow and thanks | Notices an unusual inhabitant that players often run straight past. A different subject and action from the two earlier Teldrassil additions | Check the recorded patrol corridor against the native client. The independent Questie check and target-plus-location restriction are implemented |
| Dun Morogh | The user's abandoned camp near Rumbleshot | Find the camp itself, solved by arrival | The original player-observed scene, with an empty camp and a visiting bear | The user confirms the scene just metres south of spawn 270. Check the ten-yard fixed footprint at the actual camp's edge. Neither a live bear nor targeting it is required |
| Badlands | The crypt above the dwarf camp | Reach the actual chamber, solved by arrival | A distinctive overlooked scene in a one-riddle zone | Check the sword's footprint and interior detection in each native client. The fixed object and independent Questie position are now established |
| Stonetalon Mountains | The abandoned logging camp | Reach and recognize the camp, solved by arrival | Adds a forgotten place to another one-riddle zone | Verify a route that does not depend on terrain exploits, the present scene and its footprint. Do not invent an explanation for its abandonment |
| Arathi Highlands | The remote coastal dwarf farm | Find the farm by the coastal approach, solved by arrival | Rewards a journey to a place outside the usual quest roads | Check the coastal approach and the stable footprint in each client. Fixed ram spawns and Questie agree. The danger line warns Horde visitors. No history has been invented for the residents |

The two Dolanaar additions bring Teldrassil from two to four riddles.
The hidden places deserve arrival
solutions where finding them is the whole discovery. Do not attach arbitrary
gestures merely to vary the action column.

### More Teldrassil: Keldamyr's invitation

**Implemented locally. Both games, Alliance. In-game verification remains.**

- Subject: Innkeeper Keldamyr, creature **6736**. Questie places him at
  **55.62, 59.79**. Classic world spawn and the frozen Classic Wowhead point
  agree near **55.6, 59.8**. The Forever database inherits the Classic world
  placement and also has the Questie point. That is not a Forever playtest.
- Story: his [ordinary welcome](https://warcraft.wiki.gg/wiki/Innkeeper_Keldamyr)
  invites a weary visitor to rest and entrust their dreams to Elune. The
  same text exists in wow-data as English broadcast text **2827**, but that
  table does not itself attach a speaker. The attribution comes from the
  linked transcription, retrieved through the search index. Guard directions
  **7076** and **7077** independently describe the inn as a place to rest.
- Quest context: **2159, Dolanaar Delivery**, ends at Keldamyr in both
  databases. Its reward text also encourages rest. Yonder would ask for a
  gesture, without the delivery item, accepting or completing the quest,
  changing the hearthstone bind, buying a room or waiting for rested XP.
  That distinction is recorded as an explicit reviewed overlap.
- Accepted action: **SLEEP** and **LAYDOWN** near the keeper, inside the inn.
  Both are real tokens in both clients and share EmoteID **12**. Neither
  requires targeting Keldamyr. Do not accept sitting as sleeping unless the
  final verse deliberately asks for the broader act of taking a seat.
- Implementation: a stationary `found: place` creature anchor is already
  supported. Measure where its small footprint actually lands. Being under
  the inn, outside a wall or merely crossing the road must not be enough.
  If the keeper's footprint cannot represent the interior fairly, use a
  properly verified interior landmark rather than inflating its radius.
- Limits: no night-time requirement, countdown or magical gameplay benefit.
  His words about Elune describe his welcome, not proof of an Emerald Dream
  visit or a moonwell-like effect. Exclude Season of Discovery's additional
  patron dialogue from the shared story.

Authored English verse, with French, German and Spanish translations:

> Dolanaar has a roof for the road-weary.
> Its keeper leaves your dreams in Elune's care.
> Let the next errand wait a little.
> Close your eyes and travel nowhere.

Paid hint direction: **At the inn in Dolanaar, take the keeper's invitation
and lie down to rest.** General emote instructions remain on the riddle page.

### More Teldrassil: a tree on watch

**Implemented locally with a patrol restriction. Both games, Alliance.**

- Subject: **Ancient Protector, creature 2041**. The Questie Dolanaar point
  is **57.24, 57.41**. Classic spawn **49855** is on map **1** at world
  **9882.95, 900.002, 1307.93**, with movement type **2** and a **43-point
  path**. Both databases carry these reconstructed records. The complete
  patrol must inform a hint, rather than treating the spawn as a stationary
  tree. Wowhead's tooltip returns Darnassus rather than Dolanaar. The explicit
  independent check therefore uses Questie's Teldrassil point.
- Story: the discovery is a living tree carrying out a village guard's
  patrol. Original-era quest **4441, Felbound Ancients**, describes ancient
  protectors as treant allies of the night elves. It supports the broad
  relationship, not a personal biography for Dolanaar's particular guard.
- Proposed action: **SALUTE**, **BOW** and **THANK**, all present in both
  clients. The verse should suggest respect for a watchman. The paid hint
  can name a salute. No fighting, waiting for combat or interrupting its
  patrol should be required.
- Quest checks: no direct giver, ender or creature-objective relation for
  **2041** was found in either database. That does not rule out every script.
- Integration: the same creature ID also has Teldrassil placements near
  Darnassus. The current `found: target` solution accepts a nearby matching
  creature ID anywhere in the zone. A small hint circle only selects source
  positions at build time, it does not limit that runtime target fallback.
  The new `found: patrol` mode resolves the selected spawn's actual route,
  samples its segments and requires the nearby target inside that corridor.
  This keeps the Dolanaar verse from accepting a protector by the city gate.
  A moving NPC remains unsuitable for the stationary `found: place` anchor.
- Verify: the full ordinary patrol, targetability and friendly interaction,
  independent position evidence, and the agreed locality rule in both games.
  Test that the intended guard solves it and the distant protector does not.

### Other Teldrassil NPCs considered

| Subject | Evidence and decision |
| --- | --- |
| Zarrin, **6286**, behind the inn | His quest **4161, Recipe of the Kaldorei**, has a worthwhile lesson about taking only what is needed. A conversation about that lesson is a reserve concept. Do not pretend it is ordinary gossip available without Cooking, or turn the recipe's collection objective into another errand. Forever also links him to **96634, Camping 101: Cooking**. We already have a profession trainer's hospitality riddle at Nadyia, so another generic greeting adds little |
| Seriadne, **10051**, outside the inn | Questie places her at **56.63, 59.62**. Broadcast texts **8530** and **8531**, also transcribed among [Teldrassil Sentinel directions](https://warcraft.wiki.gg/wiki/Teldrassil_Sentinel), describe her care for animals. No direct quest relations were found in either database. Keep as a reserve until there is a particular interaction or overlooked detail worth discovering. Do not require a hunter pet, stabling a pet or petting an NPC |
| Tallonkai Swiftroot, **3567** | His Classic placement is high in the tree-house, but a generic greeting to a prominent quest giver is weak. The existing target fallback also cannot prove that a player climbed to the correct floor. His dreamcatcher story is already a quest objective. Reserve only if a separate observation earns a riddle |
| Lyreena Duskblade, **265811**, Forever only | Her camp looks suitable for a rest riddle, but **96606, The Great Outdoors**, explicitly requires sitting near her campfire and waiting for the rest buff. That would repeat the quest's action. Exclude it in favour of Keldamyr's separate inn invitation |

Keep both existing Teldrassil additions. Another moonwell would repeat the
Shadowglen discovery, while an emote chosen only to pad the zone would make
the expansion weaker. Keldamyr and the protector add different observations
without requiring a new route through high-level territory.

## Retained Forever-specific candidates

These are still part of the refined list. The earlier
[15 October research](riddle-expansion-research-2026-10-15.md#earlier-database-candidates)
contains the attributed lines, IDs and source limitations. They have stronger
individual stories than many generic shared-world NPCs, but they need more
evidence or resolver support before implementation.

| Place | Proposed riddle | Intended action | Specific blocker |
| --- | --- | --- | --- |
| Shen'dralas | The citizen who dislikes tourists, **251343** | An apology that answers the attributed complaints, using **APOLOGIZE** | Verify persistent availability, friendliness, targetability and an independent position. The data categorizes the citizen as undead, so do not assume a living resident |
| The Drunken Dwarf, Wetlands | An audience for performer **272612** | Applause or another coherent appreciative gesture supported by the actual performance | The performer has no spawn record. Tavern staff do not establish the performer's location. Verify the encounter and add explicit Forever-only riddle support inside a shared zone |
| Riverglades | One Brotherhood history plaque or a coherent memorial scene | Read a verified text. Consider mourning only if the recovered text supports it | Recover the readable pages of **667573** or **668544**, or the named markers, and corroborate position and access. Add Forever object resolution. Do not turn the compact memorial group into nine similar riddles |
| Zephras Isle | One recording, preferably **671478, The Sky-Touched Mystery**, or **658837, The Shal'nan's Abdication** | Read or use the actual verified interaction | Recover its contents and establish object type, stable displayed title and interaction events. Do not assume a recording uses the Classic book event. Avoid revisiting the Shal'nan tree already covered in an existing margin |
| Zephras Isle | A farewell at one dockmaster, **275269** or **275270** | **BYE** or **WAVE**, as a departure gesture | Verify faction access, permanent presence, movement and independent positions. Choose one coherent subject. No ship ride, timetable, announcement or waiting requirement |

## Other scenery leads and exclusions

These remain research leads after the six shared-world priorities above.

| Lead | Priority | What remains before a riddle can ship |
| --- | --- | --- |
| Stonetalon empty cave and waterfall | Secondary | [A firsthand Classic exploration post](https://www.reddit.com/r/classicwow/comments/1hc49tc) supplies leads. Confirm which scene the route reaches, and keep it distinct from the logging camp |
| Tanaris underwater village | Conditional | Verify dive route, depth, usable footprint and whether a normal character has enough breathing time. Do not make water-breathing or a death trip an unstated requirement |
| Stranglethorn secret cave | Conditional | The five-location inventory names it but does not establish its identity here. Find its exact cave and distinguish Classic scenery from later occupants |
| Newman's Landing | Worth investigating, lower coverage priority | A [firsthand Classic visit](https://www.reddit.com/r/classicwow/comments/d98ltj) confirms a swimming visit. Check the long approach and Forever's changes. Do not repeat the speculative character-spawn explanation as fact |
| Southern Kalimdor tauren camp | Conditional | Establish the actual zone and ordinary coastal route. The forum report alone does not supply a production location |
| Shatterspear village | Hold | Confirm ordinary access. A closed valley reached by terrain exploits should not become a required journal visit |
| Wetlands farm and Ironforge airport | Hold | Verify current access separately for each game. Familiar exploration videos often use old climbing routes |
| Southern Tanaris islands | Low | Check fatigue, route, danger and existing quest use. Hidden is not sufficient reason to send an ordinary explorer there |
| Old Ironforge, GM/developer islands, closed Hyjal, behind sealed crypt gates | Exclude from this batch | Sealed or test content and routes through geometry do not make reliable ordinary exploration riddles. Reassess separately if Forever officially opens a location |

These leads must not be entered as fabricated game objects or arbitrary
coordinates in an expedition file. Unnamed scenery needs a verified landmark
record through wow-data if no existing object, trigger or narrow named area
can identify the actual scene. Keep both clients' evidence, and account for
height when another accessible surface sits under the same map position.

## Suggested authoring order

1. Finish the in-game checks for the four first-batch and five second-batch
   additions. They do not depend on enabling the Stonetalon draft.
2. Check Keldamyr's indoor footprint and the protector's patrol in Dolanaar,
   including the rejection of another protector outside the village.
3. Check the Dun Morogh camp's southern edge, the crypt's throne chamber
   and the Arathi farm's stable and approach. Establish ordinary access and
   a sourced landmark for Stonetalon before enabling its draft. The list
   must not turn missing coordinates into guesswork.
4. Recover the distinctive Forever encounters' missing text and placement
   in parallel with scenery research, without promising them for a release.
   Review English verse, action, paid hint, note and margin before translating
   each accepted addition into French, German and Spanish. Keep each locale's
   game names and accept the same coherent actions across clients.

## Remaining thin zones

Ten expedition zones still have one riddle: Alterac Mountains,
Dustwallow Marsh, Felwood, Silverpine Forest, Stonetalon Mountains, Swamp of
Sorrows, Thousand Needles, Un'Goro Crater, Western Plaguelands and Winterspring.
The crypt brings Badlands to two. Stonetalon's logging-camp lead remains
unresolved. The web inventory does not establish a worthwhile, technically
locatable addition in every thin zone. Filling the rest with generic vendor
greetings would hide the coverage issue rather than improve the journal.

The earlier [15 October research](riddle-expansion-research-2026-10-15.md)
contains additional Forever encounters and their missing evidence. Its old
blanket quest exclusion and one-arrival quota are superseded by this document.
The user's follow-up places the Dun Morogh camp just metres south of the
corroborated bear spawn. Its narrow implemented footprint is documented
above and still needs a check at the camp's actual edge.

## Verification limits

The generated solution matrix checks every authored riddle in twelve client
locales, in both game accounts and through both emote APIs. Additional checks
exercise the moonwell without a target, reject other moonwells and mere
arrival, and keep the faction and combat gates. The complete build checks
source freshness, localized answer names and translated fields.

This is automated verification. The implemented new visits still need a normal
in-game playtest, including reading the Auberdine book and standing at the
moonwell's edge. Web sources do not prove Forever's current terrain route.

The second batch adds five riddles, their translations and the runtime
constraints described above. The Stonetalon draft is not loaded by the addon.
All-locale interaction checks exercise both emote APIs, reject the wrong
protector, outdoor inn and crypt positions, and a live animal used as a target
elsewhere. Camp arrival and the mortar gesture do not solve each other's
riddles in the simulated game. Native geometry and the camp's exact footprint
still need checking in the test build. These are not claimed as live playtests.

New local research used wow-data's read-only Python API, not raw caches. Both database
snapshots were built on **17 October 2026**, Classic **1.15.9.70003** and
Forever **1.60.1.70425**. Queried tables include `creature`, `spawn`, `path`,
`name`, `speech`, `npc_line`, `quest_relation`, `quest_objective`, `quest_text`
and `client_EmotesText`. NPC-to-gossip links are still absent for the Dolanaar
subjects, so a matching broadcast text is not independently attributed by
the database. The web transcriptions and quest text support a proposal,
not a claim that the interaction was checked on a live character.
