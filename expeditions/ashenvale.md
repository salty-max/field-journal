---
zone: 1440   # Ashenvale
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: ashenvale-mel-thandris
    tier: near
    reading: Ancient Inscription
    object: 19025   # dump 50.3, 39.6; Wowhead 50.3, 39.6
    hint_area: { x: 52.7, y: 42.8, r: 8 }
    danger: "Guarded (worgen)"
    sources: "object 19025's text; quests 1022, 1037-1044"
  - id: ashenvale-grom
    tier: off
    gestures: [SALUTE, BOW, KNEEL]
    object: 21004   # dump 82.8, 79.1; Wowhead 82.9, 79.1
    hint_area: { x: 81.8, y: 83.0, r: 8 }
    danger: "Perilous (the Legion's servants)"
    sources: "object 21004's text; object 175742's text; the Codex's demon-fall-canyon page"
  - id: ashenvale-elunes-tear
    tier: off
    gestures: [PRAY]
    object: 19015   # object 19015, eight spawns on the isle: dump 46.1-46.3, 45.9-46.6; Wowhead 46.0-46.6, 45.9-46.9
    hint_area: { x: 45.6, y: 48.8, r: 5 }
    danger: "Quiet"
    sources: "quests 1033, 1034, 1035"
  - id: ashenvale-hidden-shrine
    tier: hidden
    object: 19024   # dump 56.4, 49.2; Wowhead 56.4, 49.2
    hint_area: { x: 58.6, y: 45.8, r: 8 }
    danger: "Guarded"
    sources: "quests 1028, 1055; Shael'dryn (creature 3916) at 53.5, 46.2"
  - id: ashenvale-teronis
    tier: hidden
    gestures: [MOURN]
    creature: 3891   # Teronis' Corpse, dump 20.3, 42.3; Wowhead 20.2, 42.2
    hint_area: { x: 18.2, y: 43.6, r: 5 }
    danger: "Guarded (murlocs)"
    sources: "quests 1023, 1024, 1028"
  - id: ashenvale-astranaar
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Charge of the Dragonflights
    object: 175726   # dump 34.8, 49.7; Wowhead 34.8, 49.8
    hint_area: { x: 31.9, y: 52.5, r: 8 }
    danger: "Quiet"
    sources: "object 175726's text; the Codex's dragons-of-nightmare page"
  - id: ashenvale-splintertree
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 12696   # Senani Thunderheart, dump 73.8, 61.5; Wowhead 73.6, 61.4
    hint_area: { x: 73.5, y: 64.0, r: 5 }
    danger: "Quiet"
    sources: "quests 6382, 6383"
  - id: ashenvale-zoramgar
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 12736   # Je'neu Sancrea, dump 11.6, 34.3; Wowhead 11.6, 34.2
    hint_area: { x: 9.8, y: 36.0, r: 5 }
    danger: "Quiet"
    sources: "quests 824, 6564, 6565"
# quarry: the zone's own, in the hunts' pass
---
## ashenvale-mel-thandris
Near the border of the fel-touched woods, wolf-men took a shrine,
and their howling named its vale.
Its stone still prays that the moonlight shine there forever.
? The Howling Vale, north of the road, near the Felwood border.
= The Shrine of Mel'Thandris: 'May the light of Elune shine upon this vale eternal and illuminate the ways of the forest as it has for time immemorial.'
+ The priestess Velinde Starsong watched over Felwood from here, then vanished with the Scythe of Elune; her trail runs through Ratchet and Booty Bay to the mines of Duskwood.

## ashenvale-grom
In a canyon where demons still walk,
a warchief carved words for his big brother,
whose name meant giant's heart,
who stood alone before the demon and bought his people's freedom with his blood.
Leave him what a warrior is owed.
? Demon Fall Canyon, in Ashenvale's south-east.
= 'Lok'Tar ogar, big brother. May the Warsong never fade.' Thrall wrote it.
+ Grom was the first chieftain to drink Mannoroth's blood, and the one who killed the demon: 'the curse of our people began and ended with Grom.'

## ashenvale-elunes-tear
A stone that washes away corruption rests in only one place:
a small isle on the lake east of the sentinels' town.
A father there hopes it will save his daughter from her sickness.
Find the stone, and ask for what he asks.
? The isle on Iris Lake, east of Astranaar; the father is asking a goddess.
= Elune's Tear, on the isle of Iris Lake. Pelturas Whitemoon puts it in a stew for his daughter, Relara.
+ It washed away some of her sickness; her fever needed the frosted dust of the Ruins of Stardust, and her strength a moonstone from Fallen Sky Lake.

## ashenvale-hidden-shrine
A shrine with the power to wake an old rod
hides in the mountains that ring a glade.
There are very few paths, and they are narrow:
keep your eyes to the north, and find it.
? South-east of the moonwell where Shael'dryn waits, in the hills that ring the glade.
= The hidden shrine. Dartol's rod was made whole again in its basin.
+ Shael'dryn says rebuilding the rod was simple; finding the shrine with the power to recharge it was the hard part.

## ashenvale-teronis
By a lake in the west of the forest, one of the sentinels' own
lies where he died looking for a glowing gem.
His journal survived him; the murlocs kept the gem,
and his friends in the town have not yet been told. Find him.
? Lake Falathim, west of Astranaar.
= Teronis. Raene Wolfrunner did not know he was dead until his journal came back without him.
+ His task was Dartol's rod: rebuilt from its pieces, it is made whole again at the hidden shrine in the hills.

## ashenvale-astranaar
In the sentinels' town by the lake, a history tells
how the Titans chose five dragons to keep the world,
and gave one of them the Dream to watch over in her sleep.
? Astranaar.
= Charge of the Dragonflights, in Astranaar.
+ Ysera fell into an eternal trance, bound to the waking Dream of Creation; her green dragons keep its doors, the great tree of Duskwood's Twilight Grove among them.

## ashenvale-splintertree
In the outpost north of the plains' road, a huntress keeps the tally
of a great hunt: a bear, a nightsaber and a hippogryph,
the forest's legends, for whoever would test themselves.
Find the one who keeps the hunt.
? Splintertree Post.
= Senani Thunderheart, and the Ashenvale Hunt: Ursangous, Shadumbra and Sharptalon.
+ 'In the process, you will hopefully learn something about yourself.'

## ashenvale-zoramgar
On the western strand, near a drowned temple, a shaman of an old circle
studies the water spirits a cult has fouled,
and the name of the old god it means to wake. Find him.
? Zoram'gar Outpost, on the Zoram Strand.
= Je'neu Sancrea, of the Earthen Ring.
+ The Twilight's Hammer would appease Aku'Mai and bring back 'an era of rule by the Old Gods'.
