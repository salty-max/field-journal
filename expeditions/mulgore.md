---
zone: 1412   # Mulgore
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: mulgore-ravaged-caravan
    tier: near
    gestures: [SEARCH, LOOK]
    area: Ravaged Caravan   # placed: the client's overlay: 54.4, 47.2, half-size 4.0 by 4.5
    hint_area: { x: 53.0, y: 46.0, r: 8 }
    danger: "Quiet"
    sources: "quests 749, 751"
  - id: mulgore-thunderhorn-well
    tier: near
    gestures: [DRINK]
    area: Thunderhorn Water Well   # placed: the client's overlay: 44.7, 45.7, half-size 3.2 by 5.2
    hint_area: { x: 45.5, y: 44.0, r: 8 }
    danger: "Quiet"
    sources: "quests 748, 754, 758"
  - id: mulgore-red-rocks
    tier: off
    gestures: [KNEEL, BOW, PRAY]
    area: Red Rocks   # placed: the client's overlay: 61.1, 20.2, half-size 5.7 by 9.0
    hint_area: { x: 59.5, y: 22.0, r: 11 }
    danger: "Quiet"
    sources: "the Codex's red-rocks page; quest 833"
  - id: mulgore-three-hammers
    tier: hidden
    reading: War of the Three Hammers
    object: 175739   # dump 31.6, 49.4; Wowhead 31.6, 49.4
    hint_area: { x: 29.5, y: 52.8, r: 8 }
    danger: "Guarded (the Bael'dun dwarves)"
    sources: "object 175739's text; quest 843"
# quarry: the zone's own, in the hunts' pass
---
## mulgore-ravaged-caravan
On the north shore of the bull's lake, a caravan burned:
its guards beaten, its crates left to the torches.
The torches were careless. What the crates still hold
tells what the goblins meant to take from the land.
? North of Bloodhoof Village, on the shore of Stonebull Lake; the crates are worth going through.
= The Ravaged Caravan. Its crates bear the stamp of the Venture Co. Mining Division.
+ The Outrunners fell on it because they had lost two of their own in an earlier battle. Up in the eastern foothills, the Venture Co.'s mine still smokes.

## mulgore-thunderhorn-well
North of the hoof-print village, by the road to the bluffs,
a sacred well was poisoned by goblins and their servants,
until a totem was carried to it and the water made clean.
The beasts came back to it first. Do as they did.
? The Thunderhorn Water Well, north of Bloodhoof Village, near the road.
= The Thunderhorn Water Well, clean again.
+ The Thunderhorn ancestors spoke to Mull Thunderhorn in a dream, praising whoever cleansed their well.

## mulgore-red-rocks
Not every tauren is laid beneath these stones:
only the bravest, and the founders' bones.
The young come here for the last of their rites,
and the honoured spirits are said to walk there still.
Show them the respect the earth shows them, east of the bluff.
? East of Thunder Bluff, among great red stones.
= Red Rocks, where the tauren lay their most valiant. The quilboar have been digging in the graves.
+ The old lorekeeper who tends the graves is past fighting the quilboar off. Whoever does it for him makes a friend of every tauren in Mulgore.

## mulgore-three-hammers
In the western cliffs, far from their own mountain,
dwarves have cut a quarry into the tauren's land,
and keep among their picks a history of their own:
three hammers, a firelord woken, two kings in stone.
? The Bael'dun Digsite, in Mulgore's western cliffs.
= War of the Three Hammers, at the Bael'dun Digsite. The diggers brought their own history to someone else's land.
+ Their kin dig at Bael Modan, in the Barrens, where Gann Stonespire wants them driven out by force: 'He was an infidel on these lands.'
