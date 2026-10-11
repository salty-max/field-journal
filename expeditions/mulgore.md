---
zone: 1412   # Mulgore
home: horde   # a starting zone: its riddles are its faction's alone, as a capital's
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: mulgore-near
    tier: near
    area: Ravaged Caravan   # placed: the client's overlay: 54.4, 47.2, half-size 4.0 by 4.5
    hint_area: { x: 53.0, y: 46.0, r: 8 }
    danger: "Quiet"
    sources: "quests 749, 751"
  - id: mulgore-off
    tier: off
    gesture: KNEEL
    area: Red Rocks   # placed: the client's overlay: 61.1, 20.2, half-size 5.7 by 9.0
    hint_area: { x: 59.5, y: 22.0, r: 11 }
    danger: "Quiet"
    sources: "the Codex's red-rocks page"
  - id: mulgore-hidden
    tier: hidden
    reading: War of the Three Hammers
    object: 175739   # dump 31.6, 49.4; Wowhead 31.6, 49.4
    hint_area: { x: 28.2, y: 47.2, r: 8 }
    danger: "Guarded (the Bael'dun dwarves)"
    sources: "object 175739's text; quest 843"
# quarry: the zone's own, in the hunts' pass
---
## mulgore-near
On the north shore of the bull's lake, a caravan burned:
its guards beaten, its crates left to the torches.
The torches were careless. The papers in one crate
showed what the goblins meant to take from the land.
? North of Bloodhoof Village, on the shore of Stonebull Lake.
= The Ravaged Caravan. Its crates bear the stamp of the Venture Co. Mining Division.
+ The Outrunners fell on it because they had lost two of their own in an earlier battle. Up in the eastern foothills, the Venture Co.'s mine still smokes.

## mulgore-off
Not every tauren is laid beneath these stones:
only the bravest, and the founders' bones.
The young come here for the last of their rites,
and the honoured spirits are said to walk there still.
Kneel where the earth keeps them, east of the bluff.
? East of Thunder Bluff, among great red stones.
= Red Rocks, where the tauren lay their most valiant. The quilboar have been digging in the graves.
+ The old lorekeeper who tends the graves is past fighting the quilboar off. Whoever does it for him makes a friend of every tauren in Mulgore.

## mulgore-hidden
In the western cliffs, far from their own mountain,
dwarves have cut a quarry into the tauren's land,
and keep among their picks a history of their own:
three hammers, a firelord woken, two kings in stone. Read it there.
? The Bael'dun Digsite, in Mulgore's western cliffs.
= War of the Three Hammers, at the Bael'dun Digsite. The diggers brought their own history to someone else's land.
+ Their kin dig at Bael Modan, in the Barrens, where Gann Stonespire wants them driven out by force: 'He was an infidel on these lands.'
