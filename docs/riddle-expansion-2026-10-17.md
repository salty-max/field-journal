# Riddle expansion and hidden-place inventory

Research and local implementation: 17 October 2026. Nothing pushed or released.
The frozen position additions are in local wow-data commit `d8d1cfe`.
That data commit must precede Yonder when these changes are eventually pushed.

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

The total becomes 114 Forever riddles and 110 Classic riddles. All starting
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

## Candidate triage

| Lead | Priority | What remains before a riddle can ship |
| --- | --- | --- |
| Badlands crypt above the dwarf camp | High, fills a one-riddle zone | Verify the walking approach, actual chamber footprint and static scenery in each game. No verified standalone object or sub-area anchor has been established. Do not award it merely for standing at the camp below. |
| Arathi coastal dwarf farm | Good hidden-place lead | Verify route, present inhabitants, faction access, exact scene and footprint. No made-up account of its residents. |
| Stonetalon abandoned logging camp | High research value for a thin zone | Verify that ordinary walking reaches it on the actual client. The explorer guide warns that reaching its spots takes effort. Do not assume old terrain tricks still work. |
| Stonetalon empty cave and waterfall | Secondary | [A firsthand Classic exploration post](https://www.reddit.com/r/classicwow/comments/1hc49tc) supplies leads. Confirm which scene the route reaches, and keep it distinct from the logging camp. |
| Tanaris underwater village | Conditional | Verify dive route, depth, usable footprint and whether a normal character has enough breathing time. Do not make water-breathing or a death trip an unstated requirement. |
| Stranglethorn secret cave | Conditional | The five-location inventory names it but does not establish its identity here. Find its exact cave and distinguish Classic scenery from later occupants. |
| Newman's Landing | Worth investigating, lower coverage priority | A [firsthand Classic visit](https://www.reddit.com/r/classicwow/comments/d98ltj) confirms a swimming visit. Check the long approach and Forever's changes. Do not repeat the speculative character-spawn explanation as fact. |
| Southern Kalimdor tauren camp | Conditional | Establish the actual zone and ordinary coastal route. The forum report alone does not supply a production location. |
| Shatterspear village | Hold | Confirm ordinary access. A closed valley reached by terrain exploits should not become a required journal visit. |
| Wetlands farm and Ironforge airport | Hold | Verify current access separately for each game. Familiar exploration videos often use old climbing routes. |
| Southern Tanaris islands | Low | Check fatigue, route, danger and existing quest use. Hidden is not sufficient reason to send an ordinary explorer there. |
| Old Ironforge, GM/developer islands, closed Hyjal, behind sealed crypt gates | Exclude from this batch | Sealed or test content and routes through geometry do not make reliable ordinary exploration riddles. Reassess separately if Forever officially opens a location. |

These leads must not be entered as fabricated game objects or arbitrary
coordinates in an expedition file. Unnamed scenery needs a verified landmark
record through wow-data if no existing object, trigger or narrow named area
can identify the actual scene. Keep both clients' evidence, and account for
height when another accessible surface sits under the same map position.

## Remaining thin zones

Eleven expedition zones still have one riddle: Alterac Mountains, Badlands,
Dustwallow Marsh, Felwood, Silverpine Forest, Stonetalon Mountains, Swamp of
Sorrows, Thousand Needles, Un'Goro Crater, Western Plaguelands and Winterspring.
The web inventory supplies stronger leads for Badlands and Stonetalon. It does
not establish a worthwhile, technically locatable addition in every one of
those zones. Filling the rest with generic vendor greetings would hide the
coverage issue rather than improve the journal.

The earlier [15 October research](riddle-expansion-research-2026-10-15.md)
contains additional Forever encounters and their missing evidence. Its old
blanket quest exclusion and one-arrival quota are superseded by this document.
The Dun Morogh camp remains a useful scenery lead, with the previously
identified bear spawn only a search clue, not a measured camp footprint.

## Verification limits

The generated solution matrix checks every authored riddle in twelve client
locales, in both game accounts and through both emote APIs. Additional checks
exercise the moonwell without a target, reject other moonwells and mere
arrival, and keep the faction and combat gates. The complete build checks
source freshness, localized answer names and translated fields.

This is automated verification. The four new visits still need a normal
in-game playtest, including reading the Auberdine book and standing at the
moonwell's edge. Web sources do not prove Forever's current terrain route.
