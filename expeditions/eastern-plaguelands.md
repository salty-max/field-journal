---
zone: 1423   # Eastern Plaguelands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: eastern-plaguelands-mirador
    tier: off
    gestures: [PET]
    creature: 11710   # Mirador, dump 7.4, 43.5, outside Tirion Fordring's cottage
    hint_area: { x: 9.0, y: 45.0, r: 4 }
    danger: "Quiet"
    sources: "the WoWWiki archive's Mirador page; Of Blood and Honor (2001: Tirion, Eitrigg, the exile); the dump's spawn"
  - id: eastern-plaguelands-adon
    tier: hidden
    gestures: [BOW, SALUTE, GREET, WAVE]
    creature: 11706   # Adon, dump 58.4, 16.9, at the road north to Quel'Thalas
    hint_area: { x: 57.0, y: 19.0, r: 4 }
    danger: "Perilous (the Scourge of the north road)"
    sources: "the WoWWiki archive's Adon and Quel'Lithien Lodge pages; the dump's spawn and faction (friendly to all)"
quarry:
  id: 10821   # Hed'mush the Rotting
  sources: "the WoWWiki archive's Hed'mush the Rotting page (an undead ogre, glowing green); the dump's spawns (three towers, one at a time) and respawn (32 to 48 hours)"
---
## eastern-plaguelands-mirador
Where the river runs between the two plaguelands, an old knight lives in exile in a cottage,
and outside it his horse waits, as if a war might call any day.
Make a friend of the horse.
? The Thondroril River, at the Eastern Plaguelands' western edge, by a cottage.
= Mirador, the horse of Tirion Fordring, outside the cottage where his master lives in exile.
+ Tirion lost his lands and his title for saving the life of an orc, Eitrigg, who had once spared his own.

## eastern-plaguelands-adon
At the dead country's northern end, where the road climbs toward the elves' kingdom,
one of them stands alone at the way north, and says nothing at all.
Nobody gets past him, and nobody is sent to him. Pay him your respects all the same.
? The Eastern Plaguelands' northern edge, where the road goes on toward Quel'Thalas.
= Adon, a high elf, alone at the road north to Quel'Thalas: he has no wares, no orders and no words.
+ Close by, at Quel'Lithien Lodge, the last high elves of these lands keep a hunting lodge.

## quarry
An ogre that died and did not stay dead walks the dead country, glowing green,
by one of three old towers: the north pass, the eastern wall, or the crown guard in the south-west.
Kill him, and you will wait two days, near enough, for the next.
= Hed'mush the Rotting, an undead ogre, by Northpass Tower, Eastwall Tower or Crown Guard Tower.
+ Thirty-two hours at the least between one Hed'mush and the next; forty-eight at the most.
