---
zone: 1444   # Feralas
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: feralas-the-maul
    tier: hidden
    gestures: [FLEX, ROAR, CHALLENGE, VICTORY]
    area: The Maul   # placed: Griniblix the Spectator above it (creature 14395), dump 62.0, 30.1
    anchor: { creature: 14395 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 61.0, y: 32.0, r: 4 }
    danger: "Perilous (the Gordok ogres; and the pit lets anyone fight anyone)"
    sources: "the WoWWiki archive's Griniblix the Spectator and The Maul pages; the client's AreaTable; the dump's spawn and his words"
  - id: feralas-feathermoon
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Sentinels and the Long Vigil
    object: 175732   # dump 30.9, 42.8, on Sardor Isle
    hint_area: { x: 30.0, y: 44.0, r: 4 }
    danger: "Quiet"
    sources: "object 175732's text"
quarry:
  id: 5349   # Arash-ethis
  sources: "the WoWWiki archive's Arash-ethis page (its circle round the earth elementals); Wowhead's sightings (the Twin Colossals); the pinned dump's path and creature_ai_scripts (15117 Chain Lightning); period reports on https://www.wowhead.com/tbc/npc=5349/arash-ethis"
---
## feralas-the-maul
Among the ruins of the old elven city in the forest, the ogres have a pit,
and fighters drop into it to face whatever has come to the ring.
Above it, a goblin watches every fight and yells for all of them.
Drop in, and give him a show.
? Dire Maul's broken commons: the pit called the Maul, under Griniblix's perch.
= The Maul, the ogres' fighting pit in Dire Maul, and Griniblix the Spectator above it: 'Woohoo! They are into it now!'
+ Skarr the Unbreakable, the Razza or Mushgog may come to the ring; when Mushgog comes, herbs spring up in the pit, and some say a black lotus among them.

## feralas-feathermoon
In the sentinels' island stronghold, seek a promise between lovers
who might not see each other for centuries.
The watch these women kept began with that parting.
? Feathermoon Stronghold, on Sardor Isle.
= The Sentinels and the Long Vigil, at Feathermoon: Tyrande's warrior women, sworn to Kalimdor's defence while the druids slept in the Emerald Dream.
+ Malfurion swore they would never be apart, so long as they held true to their love; the centuries passed, and Tyrande feared the Legion's return.

## quarry
Under the two great stone pillars in the north,
earth elementals stand in the hills.
A wind serpent circles them, round and round, as if it were their keeper.
= Arash-ethis, a wind serpent, circling the earth elementals of the Twin Colossals.
+ Its lightning jumps from the one it strikes to whoever stands near.
