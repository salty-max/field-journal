---
zone: 1413   # The Barrens
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: the-barrens-ratchet-book
    tier: near
    reading: Exile of the High Elves
    object: 175731   # dump 61.9, 38.7; Wowhead 62.0, 38.7
    hint_area: { x: 63.4, y: 42.4, r: 8 }
    danger: "Quiet"
    sources: "object 175731's text"
  - id: the-barrens-lizzarik
    tier: near
    creature: 3658   # Lizzarik, Weapon Dealer: from Ratchet (dump 61.8, 38.3) to the Crossroads and back, Jorb (3659) his bodyguard
    found: target   # he never stops walking
    hint_area: { x: 56.0, y: 35.0, r: 4 }
    danger: "Quiet on the road"
    sources: "the dump's spawn, path and wares; the WoWWiki archive's Lizzarik page (his road, Jorb)"
  - id: the-barrens-tidus-stair
    tier: off
    area: The Tidus Stair   # placed: Mahren Skyseer, who fishes on it (creature 3388), dump 65.8, 43.9
    anchor: { creature: 3388 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 65.0, y: 45.0, r: 4 }
    danger: "Quiet on the stairs; deep water below"
    sources: "Warcraft: The Roleplaying Game, p. 192 (the stairs beneath the waves, the legend, the divers); the client's AreaTable"
  - id: the-barrens-pooka
    tier: off
    gestures: [WAVE, HELLO, GREET, BOW]
    creature: 14909   # Pooka, dump 47.8, 8.8, at the Mor'shan Rampart; Mogg (14908), her son, playing outside
    hint_area: { x: 47.5, y: 10.0, r: 3 }
    danger: "Quiet for the Horde; the rampart's guards for the Alliance"
    sources: "the WoWWiki archive's Pooka page (her son Mogg); the dump's spawns"
  - id: the-barrens-fallen-warrior
    tier: hidden
    gestures: [SALUTE, BOW]
    area: Shrine of the Fallen Warrior   # placed: Koiter, dump 47.4, 29.7; Wowhead 47.4, 29.6
    anchor: { creature: 12034 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 49.9, y: 28.1, r: 6 }
    danger: "Quiet"
    sources: "the wiki's Shrine of the Fallen Warrior; Koiter (creature 12034) places the hint"
quarry:
  id: 5828   # Humar the Pridelord
  sources: "the WoWWiki archive's Humar the Pridelord page (the ring of lions round his tree, his roar, his coat); the dump's spawn and respawn (8 to 12 hours)"
---
## the-barrens-ratchet-book
In the goblins' port, where every side may trade,
a history tells of the elves who would not give up their magic,
were banished for the storm they called down,
and sailed away to found a kingdom in the sun.
? Ratchet, on the Barrens' coast.
= Exile of the High Elves, in Ratchet. The goblins keep a history of elves; it is not for sale.
+ Dath'Remar mocked the druids as cowards. They could not bring themselves to put so many of their kin to death, and exiled them instead.

## the-barrens-lizzarik
On the road between the goblins' port and the orcs' crossroads,
a goblin peddler walks back and forth with weapons and potions to sell,
and an ogre walks behind him, far too strong for these plains.
Catch the peddler on the road.
? The road from Ratchet to the Crossroads; he walks it end to end.
= Lizzarik, a goblin weapon dealer of Ratchet, walking the road to the Crossroads and back with Jorb, his ogre bodyguard.
+ Jorb is of level thirty-seven, on a road most travellers walk at fifteen.

## the-barrens-tidus-stair
South of the goblins' port, great steps of ancient stone come up out of the sea,
or go down into it: the waves cover all but the highest of them.
Two tauren fish from them, as if nothing were strange about it.
Stand on the stair.
? South-east of Ratchet, on the coast.
= The Tidus Stair: a giant's stairway of ancient stone, from the beach down beneath the waves.
+ Some say it goes down to a kaldorei city the sea took when the Well of Eternity was destroyed; those who have dived as deep as they could found only more stairs.

## the-barrens-pooka
At the rampart on the northern road, where the Horde watches the elves' forest,
a mother keeps house in the middle of the war camp,
and her small son plays outside her door. Be friendly.
? The Mor'shan Rampart, at the Barrens' northern edge.
= Pooka and her son Mogg, at the Mor'shan Rampart: a family, in a war camp.
+ Of the boy's father, the rampart says nothing.

## the-barrens-fallen-warrior
Not far from the busiest road of the plains, a short trail climbs a hill
to a shrine raised for a warrior who fell,
and a spirit healer waits before it, as if for him.
Few find it. Honour him as one warrior honours another.
? West of the Crossroads, follow a ridge up a small hill.
= The Shrine of the Fallen Warrior, and its own spirit healer, Koiter.
+ It remembers Michel Koiter, who worked on this world and died before it was finished; the spirit healer bears his name, and the orc of the shrine was his own character.

## quarry
North-west of the goblins' port, beyond the hills, lions lie in a ring around a tree,
and the one at the middle has a coat unlike theirs.
He roars when he is hurt, and the ring comes running.
= Humar the Pridelord, an elite lion, under his tree north-west of Ratchet, his pride around him.
+ Eight hours at the least before he is back, and twelve at the most: hunters who want him for their own know the wait well.
