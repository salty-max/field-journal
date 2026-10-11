---
zone: 1413   # The Barrens
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: the-barrens-near
    tier: near
    reading: Exile of the High Elves
    object: 175731   # dump 61.9, 38.7; Wowhead 62.0, 38.7
    hint_area: { x: 62.4, y: 42.7, r: 8 }
    danger: "Quiet"
    sources: "object 175731's text"
  - id: the-barrens-off
    tier: off
    area: The Dry Hills   # placed: the client's overlay: 39.7, 14.6, half-size 4.7 by 5.6
    hint_area: { x: 41.5, y: 16.0, r: 8 }
    danger: "Guarded (the Witchwing harpies)"
    sources: "quests 875, 876"
  - id: the-barrens-hidden
    tier: hidden
    gesture: KNEEL
    area: Shrine of the Fallen Warrior   # placed: Koiter, dump 47.4, 29.7; Wowhead 47.4, 29.6
    hint_area: { x: 49.5, y: 31.8, r: 6 }
    danger: "Quiet"
    sources: "the wiki's Shrine of the Fallen Warrior; Koiter (creature 12034) places the hint"
# quarry: the zone's own, in the hunts' pass
---
## the-barrens-near
In the goblins' port, where every side may trade,
a history tells of the elves who would not give up their magic,
were banished for the storm they called down,
and sailed away to found a kingdom in the sun. Read it in the port.
? Ratchet, on the Barrens' coast.
= Exile of the High Elves, in Ratchet. The goblins keep a history of elves; it is not for sale.
+ Dath'Remar mocked the druids as cowards. They could not bring themselves to put so many of their kin to death, and exiled them instead.

## the-barrens-off
In the north-western hills the harpies raid the caravans
for a sister's sake: a beastmaster slew her long ago,
and the sister who leads them now has not forgotten.
Find the hills where they nest.
? North-west of the Crossroads, the Witchwing harpies hold the foothills of Stonetalon.
= The Dry Hills. Serena Bloodfeather's sister fell to Rexxar; the caravans pay for it.
+ Darsok Swiftdagger of the Crossroads wants Serena's head on the next caravan he sends out.

## the-barrens-hidden
Not far from the Barrens' busiest road, a short trail climbs a hill
to a shrine raised for a warrior who fell,
and a spirit healer waits before it, as if for him.
Few find it. Kneel there.
? West of the Crossroads, follow a ridge up a small hill.
= The Shrine of the Fallen Warrior, and its own spirit healer, Koiter.
+ It remembers Michel Koiter, who worked on this world and died before it was finished; the spirit healer bears his name, and the orc of the shrine was his own character.
