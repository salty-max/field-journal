# Yonder: riddle fairness and interaction review

15 October 2026. Contains solution spoilers. All changes applied locally.

## Verdict

The reader's Wallace report exposed a product problem, not a failure to try hard enough. The original riddle excluded waving without clearly suggesting a spoken greeting. Its paid hint repeated a location the reader had already found. The same location-only hint pattern appeared throughout the catalog.

This pass reads all **110 riddles in 47 zones**, comparing English, French and German verses and hints against the accepted actions. That is **330 authored language versions**. It improves **101 first hints** and **20 verses**, fixes NPC recognition across client languages, and makes group interactions accept the other characters the story describes.

## Scope and outcomes

| Area | Result |
| --- | --- |
| Emote riddles | All 62 reviewed. Every first hint now points to an accepted action. |
| Readable riddles | All 23 reviewed. Hints explain that the actual text must be opened and read. |
| Conversation riddles | All 17 reviewed. Sixteen hints improved, the explicit Darkshire hint retained. |
| Arrival-only riddles | All eight reviewed. Location hints retained because arriving is sufficient. |
| Authored languages | English, French and German reviewed together. Their instructions and triggers agree. |
| Other clients | All 12 client language files tested. The other locales retain their existing English riddle fallback. |

## What changed

### RF-001 — P1

Two NPC GUID parsers compare the Creature protocol token with a localized UI word.

Compare the stable literal token. All client-language loaders are exercised against real Lua solution matching.

### RF-002 — P2

Paid hints usually identify only the place, leaving the required action unexplained.

101 riddles now get an action cue in all three authored languages. Eight arrival-only riddles and the already explicit Darkshire conversation hint stay unchanged.

### RF-003 — P2

Riddle page describes gesture requirements only as something of you there.

The page explicitly says an emote is needed, localized into French and German.

### RF-004 — P2

The validator bans action verbs even in paid hints.

Keep the inference requirement in verses, allow ordinary action words in hints.

### RF-005 — P2

Group riddles recognize only the single reference NPC.

Accept the other gryphon, musical frog, orphan children and four cats by their nearby targeted creature IDs. Validate their existence, faction safety and new-quest conflicts through pinned wow-data.

### RF-006 — P2

Several verses imply waiting, physical portal access, buying goods or simply arriving.

Strengthened 20 verses across the three languages, with explicit paid hints about the actual emote, reading or conversation.

### RF-007 — P2

Natural equivalent actions are rejected in three scenes.

Blackchar accepts LOOK/GAZE/PEER, the Dead Acre accepts CRY, and the raceway accepts CLAP in addition to their existing gestures.

## Wallace: before and after

The solution remains a greeting near Wallace, with him targeted as a reliable way to identify the smith. The player must be out of combat. Opening his shop, waving, bowing and pointing do not satisfy the greeting.

### English

- Before, final line: he cannot see which side you are on. Don't bother waving.
- After, final line: he cannot see which side you are on. Let him hear a greeting.
- New hint: Under the Greymane Wall, at the south end of Silverpine, among the refugees. Stand close to the smith, target him and greet him with an emote he could hear.

### French

- Before, final line: il ne voit pas de quel camp vous êtes. Inutile de faire signe.
- After, final line: il ne voit pas de quel camp vous êtes. Faites-lui entendre vos salutations.
- New hint: Sous le mur de Grisetête, au bout sud des Pins argentés, parmi les réfugiés. Approchez-vous du forgeron, ciblez-le et saluez-le avec une emote qu'il pourrait entendre.

### German

- Before, final line: Er kann nicht sehen, auf welcher Seite du stehst. Spar dir das Winken.
- After, final line: Er kann nicht sehen, auf welcher Seite du stehst. Lass ihn deinen Gruß hören.
- New hint: Unter dem Greymane-Wall, am südlichen Ende des Silberwalds, bei den Flüchtlingen. Geh nah an den Schmied heran, nimm ihn ins Ziel und grüße ihn mit einem Emote, das er hören könnte.

## Other traps removed

- Seradane no longer suggests that waiting will open a portal. Both dream-door hints explain the sleeping or lying-down emote.
- Whispering Gardens no longer implies that the player must wait until twilight. Listening is an emote, not a wait for sound playback.
- Winkey's English verse now gives a facial-expression cue, so knowing an English name pun is unnecessary. The French cue was aligned with that meaning.
- The Maul points toward a show of strength. It does not require an arena fight.
- Moving merchants and the runner make conversation explicit. Buying goods is unnecessary.
- The Moon Glade flight-master hint says no flight is required. The inventor hint says no machine use is required.
- The Captured Servant and Mirador cues point toward reassurance or a gentle touch instead of the broader instruction to be friendly.
- The new hints identify the needed response at memorials, shrines, statues and musical performers.

## Validation

- Full `bun run check` passed, including the build and locale freshness checks, Lua lint and both complete game simulations.
- The resolver regenerated the spots through wow-data's read-only API. Only four group-target records changed. Added group members are validated against both games where applicable, including faction safety and new-quest conflicts.
- The new solution matrix exercises all accepted authored gestures and each reading, conversation and arrival solution after loading every supported client language file: **1,272 localized riddle scenarios on Classic and 1,320 on Forever**.
- It additionally checks **156 companion target scenarios**, rejecting distant or unrelated NPCs.
- The Wallace report is replayed through the actual shop event and emote hook. Wrong gestures and combat fail, a targeted nearby greeting succeeds, and using the paid clue retains the silver seal.
- A validator regression allows an ordinary action word in a paid hint while preserving the inference requirement for the verse.
- The package builds and generated locale files are checked against their source catalogs.

Existing riddle IDs, solved records and seal rules are preserved. No migration or progress reset is introduced. Changes broaden a few accepted interactions without removing any existing solution.

## Limits

The written review and simulations cannot certify equal difficulty for every player. No real-client playtest or native German signoff was performed. The German review flag remains. The other client languages have English fallback riddle prose, not newly authored translations.

The companion [audit ledger](riddle-fairness-review-2026-10-15.json) contains all 110 decisions, exact before/after verse and hint text in every authored language, accepted actions, group targets and source hashes.

## Complete riddle checklist

| Riddle | Result |
| --- | --- |
| alterac-mountains-simone | Action hint improved |
| arathi-highlands-thoradins-wall | Action hint improved |
| arathi-highlands-hammerfall | Action hint improved |
| ashenvale-grom | Action hint improved |
| ashenvale-astranaar | Action hint improved |
| azshara-ravencrest | Retained: arrival-only |
| azshara-lake-mennar | Action hint improved |
| azshara-valormok | Action hint improved |
| badlands-apocryphans-rest | Action hint improved |
| blasted-lands-dark-portal | Action hint improved |
| blasted-lands-tainted-scar | Retained: arrival-only |
| blasted-lands-nethergarde | Action hint improved |
| burning-steppes-pillar-of-ash | Action hint improved |
| burning-steppes-altar-of-storms | Retained: arrival-only |
| burning-steppes-flame-crest | Action hint improved |
| darkshore-auberdine | Action hint improved, Verse strengthened |
| darnassus-ainethil | Action hint improved |
| darnassus-darianna | Action hint improved |
| darnassus-world-tree | Action hint improved |
| deadwind-pass-deadmans-crossing | Action hint improved |
| deadwind-pass-karazhan | Retained: arrival-only |
| desolace-tethris-aran | Action hint improved |
| desolace-shadowbreak | Action hint improved, Verse strengthened |
| dun-morogh-etched-note | Action hint improved |
| dun-morogh-tog | Action hint improved |
| dun-morogh-range | Action hint improved |
| dun-morogh-fluffy | Action hint improved, Verse strengthened |
| durotar-rokar | Action hint improved |
| durotar-tiragarde | Action hint improved |
| duskwood-twilight-grove | Action hint improved, Verse strengthened |
| duskwood-callahan | Action hint improved |
| duskwood-unseen | Action hint improved |
| duskwood-darkshire | Retained: conversation already explicit |
| dustwallow-marsh-theramore | Action hint improved |
| eastern-plaguelands-mirador | Action hint improved, Verse strengthened |
| eastern-plaguelands-adon | Action hint improved |
| elwynn-forest-cats | Action hint improved, Group targets fixed |
| elwynn-forest-heroes-vigil | Action hint improved |
| felwood-morlos-aran | Action hint improved |
| feralas-the-maul | Action hint improved, Verse strengthened |
| feralas-feathermoon | Action hint improved |
| hillsbrad-foothills-zixil | Action hint improved, Verse strengthened |
| hillsbrad-foothills-gryphons | Action hint improved, Group targets fixed |
| hillsbrad-foothills-loving-memory | Action hint improved, Verse strengthened |
| hillsbrad-foothills-southshore | Action hint improved |
| hillsbrad-foothills-tarren-mill | Action hint improved |
| ironforge-great-forge | Action hint improved |
| ironforge-toothgnasher | Action hint improved |
| ironforge-tyrannistrasz | Action hint improved |
| loch-modan-valley-of-kings | Action hint improved |
| loch-modan-horde-runners | Action hint improved, Verse strengthened |
| loch-modan-thelsamar | Action hint improved |
| moonglade-flight-masters | Action hint improved |
| mulgore-rolling-plains | Action hint improved |
| mulgore-three-hammers | Action hint improved |
| orgrimmar-mannoroth-armor | Action hint improved |
| orgrimmar-orphanage | Action hint improved, Group targets fixed |
| redridge-mountains-docks | Action hint improved, Verse strengthened |
| redridge-mountains-captive | Action hint improved, Verse strengthened |
| redridge-mountains-lakeshire | Action hint improved |
| searing-gorge-stonewrought-pass | Retained: arrival-only |
| searing-gorge-blackchar | Action hint improved, Equivalent action added |
| silithus-scarab-wall | Retained: arrival-only |
| silithus-carnes | Action hint improved |
| silithus-raloshan | Action hint improved |
| silithus-glibb | Action hint improved |
| silverpine-forest-wallace | Action hint improved, Verse strengthened |
| stonetalon-mountains-sun-rock | Action hint improved |
| stormwind-city-faol-plaque | Action hint improved |
| stormwind-city-khadgar-plaque | Action hint improved |
| stormwind-city-horatio | Action hint improved |
| stranglethorn-vale-booty-bay | Action hint improved |
| stranglethorn-vale-emperors-tomb | Retained: arrival-only |
| stranglethorn-vale-gromgol | Action hint improved |
| swamp-of-sorrows-stonard | Action hint improved |
| tanaris-gadgetzan | Action hint improved |
| tanaris-zalashji | Action hint improved |
| tanaris-winkey | Action hint improved, Verse strengthened |
| the-barrens-ratchet-book | Action hint improved |
| the-barrens-lizzarik | Action hint improved, Verse strengthened |
| the-barrens-tidus-stair | Retained: arrival-only |
| the-barrens-pooka | Action hint improved |
| the-barrens-fallen-warrior | Action hint improved |
| the-hinterlands-plaguemist | Action hint improved |
| the-hinterlands-seradane | Action hint improved, Verse strengthened |
| the-hinterlands-revantusk | Action hint improved |
| thousand-needles-raceway | Action hint improved, Equivalent action added |
| thunder-bluff-white-stag | Action hint improved |
| thunder-bluff-nibbles | Action hint improved |
| tirisfal-glades-zapetta | Action hint improved |
| tirisfal-glades-stillwater | Action hint improved |
| tirisfal-glades-bulwark | Action hint improved |
| tirisfal-glades-whispering-gardens | Action hint improved, Verse strengthened |
| tirisfal-glades-terrace | Action hint improved |
| tirisfal-glades-faols-rest | Action hint improved |
| undercity-kelthuzad-book | Action hint improved |
| undercity-theresa | Action hint improved, Verse strengthened |
| undercity-terenas | Action hint improved |
| ungoro-crater-simone | Action hint improved |
| western-plaguelands-chillwind | Action hint improved |
| westfall-aegwynn | Action hint improved |
| westfall-dead-acre | Action hint improved, Equivalent action added |
| wetlands-sundown-marsh | Action hint improved, Verse strengthened |
| wetlands-terl | Action hint improved |
| wetlands-menethil | Action hint improved |
| winterspring-farflinger | Action hint improved, Verse strengthened |
| zephras-isle-swimmers | Action hint improved |
| zephras-isle-gustjumpers | Action hint improved, Group targets fixed |
| zephras-isle-zendraas | Action hint improved, Verse strengthened |
| zephras-isle-thendal-tree | Action hint improved |
