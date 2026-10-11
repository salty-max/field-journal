---
zone: 1429   # Elwynn Forest
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: elwynn-forest-lethargy
    tier: near
    reading: Lethargy of the Orcs
    object: 175751   # dump 85.3, 69.8; Wowhead 85.3, 69.7
    hint_area: { x: 85.4, y: 73.8, r: 8 }
    danger: "Quiet"
    sources: "object 175751's text; the game's Eastvale Logging Camp"
  - id: elwynn-forest-azora
    tier: off
    reading: Rise of the Blood Elves
    object: 175760   # dump 64.6, 69.4; Wowhead 64.6, 69.4
    hint_area: { x: 68.5, y: 68.7, r: 8 }
    danger: "Quiet"
    sources: "object 175760's text; quest 94"
  - id: elwynn-forest-heroes-vigil
    tier: hidden
    gestures: [SALUTE, BOW, KNEEL]
    area: Heroes' Vigil   # placed: the Stone of Remembrance, dump 74.5, 51.7 (no Wowhead position: the area solves, the stone places the hint)
    anchor: { object: 20923 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 75.0, y: 55.7, r: 8 }
    danger: "Guarded (the Defias Rogue Wizards)"
    sources: "the wiki's Heroes' Vigil and Stone Cairn Lake (the lake's shape, the ring of stones); object 20923; quests 1786-1788"
# quarry: the zone's own, in the hunts' pass
---
## elwynn-forest-lethargy
Where Stormwind's lumbermen fell the eastern trees,
a history waits among the sawdust:
how the captured Horde was penned in camps and paid for,
and how the fiercest race the kingdoms had seen
lost the will to fight behind the walls.
? The logging camps on the road east to Redridge keep more than timber.
= Lethargy of the Orcs, on a shelf at Eastvale: the internment camps, the tax King Terenas levied to keep them, and the strange listlessness that came over the prisoners.
+ Archmage Antonidas thought it no disease. The orcs were coming away from the warlocks' magic that had made them fearsome, he wrote, and their cure would have to be a spiritual one.

## elwynn-forest-azora
In a small tower whose mages spy on a rival across the mountains,
a shelf holds the story of an elven prince
who lost his homeland, then his allies,
for the magic his people could not live without.
? A mage's tower stands east of Goldshire, in sight of the road; its shelves hold more than spellbooks.
= Rise of the Blood Elves, in the Tower of Azora. A tower of mages keeps the story of a prince who could not do without magic.
+ The tower's master, Theocritus, spies on his rival Morganth in the Tower of Ilgalar, and needs someone to carry his glyph into Redridge to see further.

## elwynn-forest-heroes-vigil
In a lake shaped like a ring, an island holds a ring of stones
and a stone raised so that heroes would be remembered.
Renegade wizards hold the island now, gone over to the bandits.
Cross the water, and give the stone what it was raised for.
? The ring-shaped lake north of the road to Eastvale has an island in its middle; heroes are honoured there.
= Heroes' Vigil, and its Stone of Remembrance. The island belongs to the Defias' renegade wizards now.
+ Two paladins came here to spy on the Defias and caught them poring over documents. Henze Faulk never left the island; a paladin learning to raise the fallen is sent to bring him back.
