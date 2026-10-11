---
zone: 1442   # Stonetalon Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: stonetalon-mountains-charred-vale
    tier: near
    area: The Charred Vale   # placed: the client's overlay: 31.9, 67.0, half-size 7.5 by 10.9
    hint_area: { x: 33.0, y: 65.0, r: 12 }
    danger: "Guarded (harpies, fire elementals)"
    sources: "quests 1057, 6381"
  - id: stonetalon-mountains-boulderslide
    tier: off
    area: Boulderslide Ravine   # placed: the client's overlay: 64.9, 92.8, half-size 5.0 by 6.0
    hint_area: { x: 64.0, y: 90.0, r: 8 }
    danger: "Guarded (kobolds)"
    sources: "quest 6421; the quest's trigger in the cave (AreaTrigger 2946)"
  - id: stonetalon-mountains-kaya
    tier: hidden
    creature: 11856   # Kaya Flathoof, dump 73.5, 85.6; Wowhead 73.4, 85.6 (she walks only when escorted)
    hint_area: { x: 71.2, y: 86.6, r: 5 }
    danger: "Perilous (the Grimtotem)"
    sources: "quests 6548, 6523, 6401"
  - id: stonetalon-mountains-stonetalon-peak
    tier: town
    faction: alliance   # its town's: for that faction alone
    gestures: [BOW]
    creature: 3994   # Keeper Albagorm, dump 37.1, 8.1; Wowhead 37.0, 8.0
    hint_area: { x: 34.7, y: 8.8, r: 5 }
    danger: "Quiet"
    sources: "quest 1057; quest 1088 (the keepers, sons of the forest god)"
  - id: stonetalon-mountains-sun-rock
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 4198   # Braelyn Firehand, dump 45.9, 60.4; Wowhead 46.0, 60.4
    hint_area: { x: 47.2, y: 62.5, r: 5 }
    danger: "Quiet"
    sources: "quests 1087, 1088"
# quarry: the zone's own, in the hunts' pass
---
## stonetalon-mountains-charred-vale
South of the peak, a vale was set afire
by an army of machines that came for the forest,
and harpies and angry fire hold it now.
Seeds were meant to be planted at its heart. Stand in the ash.
? South-west of Sun Rock Retreat, the land is burned.
= The Charred Vale. Keeper Albagorm, on the peak, calls it a travesty.
+ 'In time, the Venture Co. will pack up their buzz saws and axes, the angry fire spirits will calm, and the harpies will be pushed out by the land.' Tammra Windfield, of Sun Rock.

## stonetalon-mountains-boulderslide
South-east of the retreat on the rock, kobolds dig as if driven,
deep in a cave, after a rare crystal,
and those at the retreat can feel a tension in the air.
Find the ravine.
? South-east of Sun Rock Retreat, toward the road down to the Barrens.
= Boulderslide Ravine. The kobolds mine resonite as if their lives hung on it.
+ Resonite carries a trace of Earthen magic: the kobolds may have dug down to one of the earthen, the Titans' makers of the land.

## stonetalon-mountains-kaya
When the Grimtotem burned a tauren camp at the mountains' southern edge,
her father fought his way out and believed her dead.
She is alive, in their camp, waiting for someone to come.
Find her.
? Grimtotem Post, in Stonetalon's south-east, near what is left of Camp Aparaje.
= Kaya Flathoof. Her father Makaba camps nearby; her aunt Tammra is at Sun Rock Retreat.
+ 'My goodness, my niece Kaya is alive!' Tammra Windfield, when she hears it.

## stonetalon-mountains-stonetalon-peak
High on the peak, in the kaldorei's outpost,
one of the forest's keepers stands watch over the burned valley below,
alarmed at what greed has done to the sacred hills.
Show the keeper the respect the old ones of the forest are owed.
? On Stonetalon Peak.
= Keeper Albagorm, a protector of the forest spirits.
+ The keeper sends travellers south to drive the Bloodfury harpies out of the Charred Vale, so that the land can be reclaimed.

## stonetalon-mountains-sun-rock
At the edge of the Horde's retreat on the rock, a stranger hates this land:
its druids stifle the magic the stranger craves,
and a master forbids any return home until the work is done.
Find the stranger.
? Sun Rock Retreat, at its edge.
= Braelyn Firehand, who would rather be in Jaedenar.
+ Braelyn wants the head of Ordanus, one of the eldest sons of the forest god, hidden atop a great tree at Raynewood: 'I knew Ordanus once, long ago.'
