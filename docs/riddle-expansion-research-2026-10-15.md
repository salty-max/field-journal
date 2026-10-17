# More Yonder riddles from wow-data

Research snapshot: 15 October 2026. No live riddles changed.

**17 October correction:** the owner located the Dun Morogh abandoned camp at
**39.2, 67.6** in game. The earlier bear-spawn candidate at 41.9, 66.8 was the
wrong location, despite matching the bear species. It must not be treated as
confirmation of the camp. The original research below is retained as history.

## Recommendation

The user's follow-up changes the priority: **look for forgotten places first**, including unnamed camps, remote shelters and scenery that no quest uses. Finding a place can itself be the reward. The first database survey below leaned too heavily on named NPCs and readable objects, which are easier to query than scenery.

There is also worthwhile material among the database's named entities, especially in Forever's own world: the Shen'dralar Citizen, the Drunken Dwarf's performer, the Riverglades memorials, one Zephras recording, and a farewell at Zephras' docks. These remain research candidates, not five additions ready to release. Their missing evidence is listed below.

For a modest addition with substantially more evidence already available, there is also a reading in Auberdine. It uses an existing history book, so it is less distinctive than the new Forever material.

I would not turn this into a large expansion just because the database has grown. Yonder's current 110 riddles already use many of the strongest Classic curiosities. Several tempting unused graves and shrines are explicit quest destinations. A quiet oddity with a clear action is worth more than another quest stop with a verse wrapped around it.

## What the database actually adds

These are live database totals, not a comparison against an archived earlier build.

| Evidence | Classic | Forever | Meaning for Yonder |
| --- | ---: | ---: | --- |
| Creatures | 10,387 | 13,657 | More people and animals to investigate, not necessarily persistent or friendly |
| Objects | 10,753 | 12,027 | More named props, including new memorials and recordings |
| Quests | 4,257 | 5,269 | Better material for stories and for excluding quest errands |
| Readable items | 279 | 343 | 64 additional item IDs, often letters, reports or quest instructions |
| Readable objects with English text | 108 | 108 | The current readable-object corpus has not expanded between these two databases |
| NPC-associated lines | 0 | 838 | 172 distinct speakers in Forever, currently English only |

Forever's 6,473 readable-page rows are language and page records, not 6,473 distinct texts or locations. All 838 NPC lines currently have frozen Wowhead provenance. There are no gossip-kind rows in this snapshot. The 77,728 broadcast-text rows in each game are not attached to speakers, so they cannot establish that a particular NPC says something.

There are also **43 type-9 objects with no English readable-page record**, all absent from Classic's type-9 object set. Some are new IDs for familiar exhibits or monuments. Others are genuinely promising new names. A separate group of eight named Zephras recordings has neither readable-page records nor an object type established in the database. Those eight are additional to the 43.

## Forgotten places: the Dun Morogh camp

The user describes a hidden, abandoned camp near the gunsmith in Dun Morogh, with a bear repeatedly found in a particular place. It looks as though the bear might be guarding the camp or might have eaten its occupants. **The scene is a player observation. Neither explanation is established lore.** The user's marked map and subsequent confirmation that it is a **young black bear** narrow the search to a strong candidate near **41.9, 66.8**. That is the corroborated bear spawn, not yet a measured camp footprint or verified walking route.

This is a good kind of discovery for Yonder because the question is where the camp is. The player need not solve what happened to its occupants. A solved note can describe the empty camp and the visiting bear, then leave the explanation open. Do not turn the user's possibilities into a documented massacre or invent names for the campers.

### How it should solve

- Prefer **arrival at the actual camp**, under the existing outside-combat, no-taxi and no-ghost conditions. The hidden approach and recognition of the scene carry the puzzle.
- Detect the permanent place. Do not require the bear to be alive, targeted, killed, fed or greeted. Another player can kill a normal bear before the explorer arrives.
- Use a small verified footprint around the camp, not the entire surrounding sub-area. Check approaches beneath a ledge or through a tunnel so a two-dimensional map match cannot award a visit from the wrong elevation.
- Use an emote only where the scene independently calls for one and the verse communicates it. Finding an empty campsite does not naturally imply one unique gesture.
- Do not make a photographed bear spawn the camp's identity. The same creature ID can occur throughout the zone, and the scenery remains after that spawn is killed.

Yonder already supports solving by arrival. What is missing for some unnamed scenery is an authoring source it can resolve reliably. Its current spots come from an object, a creature, a client trigger or a named sub-area. A tent or abandoned shelter may be part of the map's scenery rather than a separately listed game object. In that case it needs a verified landmark record, with per-client location and observation evidence, carried through wow-data's normal database interface. Do not invent an object ID or bypass the database with an unverified coordinate.

The existing **one arrival riddle per zone** rule is too rigid if a zone contains several genuinely different hidden places. My recommendation is to permit more than one carefully chosen discovery of this kind, rather than manufacture gestures to satisfy the quota. Keep the current rule until that deliberate design change is implemented. Dun Morogh currently has no arrival riddle, so this first camp would not require relaxing it.

### Draft based on the user's description

This is a concept draft, not production content or a verified route:

> Not far from the gunsmith, a camp lies out of sight.
> Those who made it are gone.
> A heavy-footed visitor keeps returning.
> Find what they left behind.

The final verse needs one verified feature of the approach or terrain to narrow the search. The paid hint should identify that approach and explicitly say that reaching the camp is enough. It should not send the player looking for an interaction with the bear.

The note should record the scene without closing its mystery. A possible tone is: **The camp has no campers now. The bear still comes by. Whether it found an empty shelter or helped empty it, the place gives no answer.** Treat that as speculative narrator wording, not a new lore claim, and retain it only if the verified scene supports the details.

### What the current research establishes

Hegnar Rumbleshot is creature **1243**. Classic's recorded bear spawn **270**, creature **1128 Young Black Bear**, projects to roughly **41.90, 66.79**, just southeast of his camp. That bear is configured to wander within **10 yards**, rather than stand motionless. There is no matching tent or campfire record immediately around it in the queried object spawns. That absence does not prove the scenery is absent from the game.

The user then supplied `dun-morogh copy.tiff`, a 1002 by 668 map with a red outline south of Kharanos, approximately **41.5-49.5, 63-68.5**. The outline is an approximate search area, not a surveyed boundary. Three reconstructed bear spawns fall in or near it:

| Creature | Classic spawn | Map position | Assessment |
| --- | ---: | --- | --- |
| Young Black Bear, 1128 | 270 | 41.895, 66.794 | Strong match after the user confirmed the bear's kind |
| Ice Claw Bear, 1196 | 242 | 46.346, 63.349 | Excluded by the user's clarification |
| Ice Claw Bear, 1196 | 3627 | 46.709, 63.296 | Excluded by the user's clarification |

Both database files also carry Questie points matching these locations to rounding. Their local build timestamps remain the snapshot recorded at the end of this report. This corroborates the bear's location across the imported records. It is not a live confirmation of the camp or its unchanged appearance in both clients. The bear's Classic world position is **map 0, x -6070.16, y -261.253, z 429.958**. Use that as a scouting lead, not as the camp's final solution coordinate. The user supplied the kind and scene, not an exact coordinate.

Two lookalikes must not be mistaken for this lead:

- The abandoned ammunition camp around **44.1, 56.9** has object **176785 Ammo Crate**. The stored text of Classic quest **5541 Ammo for Rumbleshot** explicitly sends the player to recover that shipment after a wendigo drove the courier away. It is well north of the user's red outline and is not the place indicated by that map.
- Web searches also return a northwestern bear camp with the Buckey brothers in a tree. A [firsthand exploration account](https://ironyca.wordpress.com/2010/12/23/secrets-and-hidden-locations-in-cataclysm/) identifies that scene as a Cataclysm-era addition. It cannot establish this camp's identity or presence in Classic or Forever.

Next evidence needed: inspect the strong candidate at **41.9, 66.8**, record the camp's static features and ordinary walking approach, verify the camp footprint independently, then check Classic and Forever separately for quest use or changes. Use the database to corroborate and exclude candidates, rather than assuming every interesting scene must already have a searchable name.

## Earlier database candidates

### 1. An unwelcome tourist in Shen'dralas

**Verdict: strong concept, needs a visit and a second position source.**

- Subject: Shen'dralar Citizen, creature **251343**.
- Place: Shen'dralas, area **16651**, UiMap **2652**. Questie point **43.24, 71.25**.
- Evidence: seven attributed speech lines complain about tourists, being crowded and disrespectful visitors. The game categorizes this creature as undead. Do not describe a living elven resident without checking the encounter.
- Proposed action: target the citizen and use an apology emote. The canonical token is **APOLOGIZE** in both pinned clients. `/sorry` is not a separate `SORRY` token.
- Why it works: the action answers the character's complaint. It does not rely on an English pun or require guessing an unrelated gesture.
- Missing: a frozen independent position, friendliness and targetability for both factions, and proof this is a persistent encounter rather than a scripted appearance. Faction and movement fields are absent. Direct quest-link and full English quest-text searches found no match, which is useful but does not prove independence from quest scripts.
- Integration: a new Forever-only expedition file is supported for this zone. No current riddle here consumes the apology gesture.

Conditional English draft, pending the visit:

> In Shen'dralas, one voice has little patience for visitors.
> You have come too close, and your manners have not helped.
> Find the citizen who would rather you had stayed at home,
> and make amends for the intrusion.

Paid hint: **Target the citizen complaining about tourists and apologize with an emote.** No purchase, combat or wait for a particular speech line should be required.

### 2. An audience at the Drunken Dwarf

**Verdict: strong action, placement unproven.**

- Subject: Performer, creature **272612**.
- Evidence: two attributed lines describe a rhythmic welcome to the Drunken Dwarf. The client separately names **The Drunken Dwarf**, area **17738**, under Wetlands **11**. Nearby Questie traces place a bartender, chef and tavern regulars around **52.7, 80.0**.
- Proposed action: an appreciative audience gesture, accepting **CLAP, APPLAUD, CHEER and DANCE** if the actual performance supports all four. These do not overlap the current Wetlands riddles.
- Missing: **the performer has no spawn record at all**. The tavern staff's positions locate the tavern, not its performer. Confirm persistence, friendliness, targetability, exact position and any event schedule before writing the final clue.
- Integration: Forever-only content in a shared zone needs client filtering at riddle level, or another explicit way to merge zone variants. Current filtering selects whole expedition files, and the shared-zone resolver uses Classic placements. Do not silently add the performer to Classic's Wetlands.
- Localization: the action is visual and social. Keep the clue independent of the English rhyme. The NPC name remains English in the stored French and German client-name records, while the tavern is localized.

### 3. Riverglades' memorials and Brotherhood history

**Verdict: highest priority for recovering missing readable text. Choose one riddle after reading it.**

- Zone: Riverglades, area **16591**, UiMap **2548**. French **Rives Claires**, German **Flusslande**.
- Historical objects: **667573 Knights of the Brotherhood** at **63.5, 83.4-83.5**, and **668544 A Wartorn Land and The Brotherhood** at **62.1, 85.6**.
- Named readable markers: **659308 Brienne Stormhart**, **659309 Sir Howard Armstrong**, **659310 Roderick the Unbroken**, **659311 Rosalind Ashwood**, **659313 Alden Amberhall**, **667574 Fern Crimsonleaf**, **688047 Lady Isolde Brightlance**. Their Questie traces form a compact group around **59.5-61.6, 84.3-85.6**.
- Evidence: all nine are marked **type 9**, a readable object. None has an English readable-page record or an independent Wowhead position in this snapshot. None is directly linked as an object quest giver, ender or objective.
- Proposed action: read one history plaque if its text contains a real discovery. Alternatively, one shared memorial riddle could accept mourning or respect at the named markers, if their texts establish that interpretation. **Do not turn nine nearby names into nine near-identical riddles.**
- Missing: the actual text, the reader's displayed titles, precise independent positions, access and faction safety, and quest-script checks. Names alone do not establish who died, what happened, or which Brotherhood this is.
- Integration: new Forever-only zone file, plus object support in `forever_zone()`. That resolver currently accepts creatures and sub-areas, not objects.

### 4. One of Zephras' recordings

**Verdict: promising discovery content with an unused reading slot, blocked by missing text and interaction metadata.**

| Object | Name | Questie point on Zephras |
| --- | --- | --- |
| 658836 | On the Shal'nan | 41.9, 23.3 |
| 658837 | The Shal'nan's Abdication | 45.1, 32.9 |
| 658838 | The Rebellion In Eldre'Thalas, Part 1 | 49.77, 56.4 |
| 658839 | The Rebellion In Eldre'Thalas, Part 2 | 64.32, 34.32 |
| 658840 | The Rebellion In Eldre'Thalas, Part 3 | 64.59, 35.12 |
| 658841 | The Rebellion In Eldre'Thalas, Part 4 | 64.7, 34.4 |
| 671478 | The Sky-Touched Mystery | 59.4, 34.4 |
| 671479 | On The Windlord | 56.0, 58.74 and 65.7, 34.16 |

These have names in English, French and German, but **no readable pages or established object type**. Names and map points are leads, not the contents of the recordings. Direct object quest links are absent, which is not a guarantee that reading them is unrelated to quests.

Prefer a recording away from the existing Haal and Meeri riddle. Its margin already mentions **On the Shal'nan**, so using that exact crystal again would revisit the same tree. **The Sky-Touched Mystery** or **The Shal'nan's Abdication** are the first texts I would recover, then judge on their contents rather than their titles.

Proposed action: reading, only after confirming these open `ITEM_TEXT_BEGIN` with a stable title. If they use a different interaction, establish that first. Do not assume a recording behaves like a Classic book. The new-zone resolver also needs object support.

### 5. A farewell at Zephras' docks

**Verdict: viable secondary idea, weaker discovery than the four above.**

- Subjects: **275269 High Order Dockmaster**, announcing Dalaran, and **275270 Windshapers Dockmaster**, announcing Mulgore.
- Questie traces: High Order around **65.0-65.7, 81.2-83.4**, Windshapers around **58.0-59.0, 78.6-81.0**. Do not use either wide range as one exact fixed position.
- Proposed action: a farewell gesture, **BYE or WAVE**, at a verified dockmaster. Zephras currently uses neither token.
- Strength: the departure gives a natural reason for the action. Both NPC names are localized in French and German.
- Missing: independent positions, friendliness, permanent availability, movement and access restrictions. There is no proof that either opens a conversation window.
- Design limit: **do not require riding the ship, boarding at a particular moment or waiting for an announcement**. The words establish the destination. They should not become a timing puzzle.
- Scope: one dock riddle if it earns its place. Do not assume both dockmasters are interchangeable companions until faction access and the wording have been checked.

## A candidate closer to implementation: Auberdine's history book

**Mount Hyjal and Illidan's Gift**, object **175729**, has a Classic world spawn that projects to **36.56, 44.03** in Darkshore. The frozen independent point is **36.6, 44.0**, within the resolver's 0.6 percentage-point tolerance. Full text and object names exist in English, French and German in Forever's database. Its object type is 9. It has no direct object quest links in either database.

Darkshore currently has a conversation riddle, so a reading would add a different deed without changing the rules. The English title is not named in Forever's new quest titles or objectives in this snapshot. A temporary expedition containing this candidate passed the full resolver, including location agreement, quest exclusions and the duplicate-deed checks. Remaining work is complete translations for the shipped languages, the build and solution checks with those translations, and an in-game interaction check. This is **a feasible draft, not a claim of a completed playtest**.

> At Auberdine, find the account of the water carried through the Sundering.
> The first Well was gone, but some of its water survived.
> Read what one brother made of it on Hyjal,
> and why the other would not thank him for the gift.

Paid hint: **In Auberdine, read the book about Mount Hyjal and Illidan's gift.**

Discovery: Illidan recreated the Well of Eternity with water preserved from the first. His people treated the act as a threat rather than a rescue. Every fact in this draft comes from the object's pages. There is no language-dependent wordplay.

My preference is still to prioritize the distinctive Forever encounters. Another history book is a sound small addition, but it will not make the expansion feel new on its own.

## Promising at first, but not first-batch material

| Lead | Evidence | Decision |
| --- | --- | --- |
| Investigators Kath'leen **275430** and Silva **275432** | Attributed lines about a worsening disturbance and keeping citizens calm. Questie records them against Alterac area 36 near **20.2-20.6, 71.3-71.4** | A listening riddle fits, but do not treat those traces as proof of an open-world Alterac encounter. City of Dalaran is Map **2959**, `InstanceType=1`, and has no dedicated UiMap in this client snapshot. Establish the actual map and runtime location support first |
| Arcanist Braedin **275398** | A conversation is cut short because someone is listening | Similar location and instance uncertainty. Also risks repeating the investigators' deed |
| Donaal Downbreeze **255940** | His complaints independently support the sailor's drunken ghost stories | Enriches the existing Swimmers riddle, not a distinct discovery |
| Ghost of Olgra **268614** | A strong line about grief and revenge, but no direct quest link | Dialogue can belong to a scripted quest scene without a `quest_relation` row. Do not assume persistent availability |
| Injured Deathguard **259377**, Forsaken Adventurer **271968**, Damaged Construct **256076** | Healing, rescue, recovery or activation language | Event-dependent appearances until demonstrated otherwise. Do not make players reproduce a hidden quest step |
| Uther's memorial, object **2082** | Readable text and positions exist | Classic quest **5861 Find Myranda** explicitly sends players to the tomb, and **8149 Honoring a Hero** uses the statue. Fails the intended overlooked-place bar |
| Yuriv's tombstone, object **24777** | Readable and placed | Quest **264 Until Death Do Us Part** explicitly uses the tomb. Reject |
| Mel'Thandris shrine inscription, object **19025** | Readable and placed | Quest **1022 The Howling Vale** explicitly sends players to this shrine. Reject |

## What to do next

1. Identify and verify the user's camp, then scout other forgotten places using observed scenery and normal walking routes. Record those the database does not yet represent, with evidence, through wow-data. Prefer a distinctive scene over a quota of additions for each zone.
2. Recover and freeze the actual object text and interaction details for the two Riverglades history plaques and the two preferred Zephras recordings. Store them in wow-data through its normal intake. Keep IDs, source and locale, rather than copying lore into an unsourced note.
3. Confirm the Shen'dralar Citizen and the performer in game. Capture the target's ID, reaction, map, position, whether it persists outside quests, and the exact interaction. The performer cannot be located from the current database alone.
4. Add Forever object resolution and explicit client selection for individual riddles before using new Forever NPCs inside shared zones. Preserve the existing deed checks unless deliberately revising the arrival limit as discussed above.
5. Write only the candidates that survive those checks. Let discovering a hidden place stand on its own when appropriate. Use broad, coherent accepted gestures where an action is justified. A paid hint must name the action when the player is already at the place.
6. Translate the whole puzzle, not merely its words. Names must match what each client displays, including English names where the database explicitly records an English fallback. Run the existing all-locale solution checks and test the actual interaction in game.

**Practical target: prioritize forgotten places, retain the five named-entity concepts as a secondary shortlist, and release the candidates that prove sound. Do not promise an addition count before the missing evidence is collected.**

## Evidence and limits

All local game-data queries used wow-data's read-only Python database API. No raw source cache was queried. The original survey fetched no external data. The forgotten-camp follow-up also consulted external exploration accounts, including the linked firsthand account used to exclude a Cataclysm-era lookalike. None of those accounts confirms the user's camp. The accompanying `riddle-expansion-evidence-2026-10-15.json` records the original survey's snapshot metadata, selected entity facts, quest checks, readable gaps and current deed usage. The follow-up's bear-spawn lead is documented above and is not a newly verified riddle in that evidence file.

Validation: the database counts and selected quest checks were asserted against the evidence file. The full expedition resolver passed with the Auberdine candidate in a temporary copy, producing 111 candidates without changing production data. The existing project's `bun run check` passed, including both clients' simulations and all-locale solution tests. No new candidate has been playtested or added to the shipped book.

- Classic database built **2026-10-15T19:17:45.672Z**, client **1.15.9.70003**.
- Forever database built **2026-10-15T19:33:21.027Z**, client **1.60.1.70374**.
- Questie pin **57931281737632202e9838f17efd5c3618d10f55**.
- CMaNGOS Classic DB pin **28ef6259c782928b08a8dc9cacf6bc02e64f2b29**.
- Tables used: `meta`, `name`, `creature`, `object`, `spawn`, `quest`, `quest_relation`, `quest_objective`, `quest_text`, `readable`, `readable_page`, `npc_line`, and client map/emote tables.
- Current content and integration checked against `expeditions/*.md`, `scripts/expeditions.py`, `scripts/expeditions.ts`, `addon/Yonder/Expeditions.lua` and `PLAN.md`. Current executable behavior takes precedence over older planning counts.
- Quest searches cover stored direct relations, objectives, titles and English quest text. They do not expose every server script, event schedule, phase, despawn condition or reaction. A missing quest link is not a clean bill of health.
- Classic world positions and Forever additions are community reconstructions or recorded traces, not live playtests. New content should retain the repository's independent position cross-check.
