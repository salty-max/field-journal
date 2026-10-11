---
zone: 1429   # Elwynn Forest
home: alliance   # a starting zone: its riddles are its faction's alone, as a capital's
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: elwynn-forest-near
    tier: near
    reading: Lethargy of the Orcs
    object: 175751   # dump 85.3, 69.8; Wowhead 85.3, 69.7
    hint_area: { x: 87.8, y: 72.9, r: 8 }
    danger: "Quiet"
    sources: "object 175751's text (the book's last pages for the margin); the game's Eastvale Logging Camp"
  - id: elwynn-forest-off
    tier: off
    reading: Rise of the Blood Elves
    object: 175760   # dump 64.6, 69.4; Wowhead 64.6, 69.4
    hint_area: { x: 61.3, y: 67.2, r: 8 }
    danger: "Quiet"
    sources: "object 175760's text; quest 94 (Theocritus and Morganth)"
  - id: elwynn-forest-hidden
    tier: hidden
    gesture: KNEEL
    area: Heroes' Vigil   # placed: the Stone of Remembrance, dump 74.5, 51.7
    hint_area: { x: 78.3, y: 50.4, r: 8 }
    danger: "Guarded (the Defias Rogue Wizards)"
    sources: "the wiki's Heroes' Vigil and Stone Cairn Lake (the ring of stones, the lake's shape); object 20923 (the Stone of Remembrance); quests 1786-1788 (Henze Faulk, the Defias Rogue Wizards)"
    check: "the Stone of Remembrance (object 20923) has no position on Wowhead: the area solves the riddle, the stone only places the hint"
# quarry: the zone's own, in the hunts' pass
---
## elwynn-forest-near
Where Stormwind's lumbermen fell the eastern trees,
a history waits among the sawdust:
how the captured Horde was penned in camps and paid for,
and how the orcs, once the fiercest of all, lost the will to fight.
Read it where the axes are.
? The logging camps on the road east to Redridge keep more than timber.
= Lethargy of the Orcs, on a shelf at Eastvale: the internment camps, the tax King Terenas levied to keep them, and the strange listlessness that came over the prisoners.
+ Archmage Antonidas thought it no disease. The orcs were coming away from the warlocks' magic that had made them fearsome, he wrote, and their cure would have to be a spiritual one.

## elwynn-forest-off
In a small tower whose mages spy on a rival across the mountains,
a book tells of a prince of the elves
who lost his homeland, then his allies,
for the magic his people could not live without.
Read it in the tower.
? A mage's tower stands east of Goldshire, in sight of the road; its shelves hold more than spellbooks.
= Rise of the Blood Elves, in the Tower of Azora. A tower of mages keeps the story of a prince who could not do without magic.
+ The tower's master, Theocritus, spies on his rival Morganth in the Tower of Ilgalar, and needs someone to carry his glyph into Redridge to see further.

## elwynn-forest-hidden
In a lake shaped like a ring, an island holds a ring of stones
and a stone raised in remembrance,
and the wizards who hold it now have gone over to the bandits.
Swim across, and kneel by the stone.
? The lake north of the road to Eastvale is shaped like a ring: look at its middle.
= Heroes' Vigil, and its Stone of Remembrance. Whoever it remembers, the island belongs to the Defias' renegade wizards now.
+ Two paladins came here to spy on the Defias and caught them poring over documents. Henze Faulk never left the island; a paladin learning to raise the fallen is sent to bring him back.
