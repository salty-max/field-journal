---
zone: 1448   # Felwood
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: felwood-morlos-aran
    tier: off
    gestures: [MOURN, SIGH, PONDER]
    area: Morlos'Aran   # placed: the client's overlay: 57.6, 87.9, half-size 3.7 by 4.1
    hint_area: { x: 57.0, y: 87.0, r: 4 }
    danger: "Guarded (felpaw wolves, angerclaw bears and ironbeak owls, levels 47 and 48)"
    sources: "the WoWWiki archive's Morlos'Aran page (its sister ruins); the dump's spawns"
quarry:
  id: 7137   # Immolatus
  sources: "the WoWWiki archive's Immolatus page (an elite infernal); the dump's path and respawn (10.5 to 16 hours)"
---
## felwood-morlos-aran
At the southern edge of the poisoned wood, the stones of an elven town still stand,
and its name ends as theirs did on the dark shore and in the forest to the south.
Stand among them, and count the others you know.
? Morlos'Aran, at Felwood's southern edge.
= Morlos'Aran, one of the old night elf settlements whose names end alike: Ameth'Aran and Bashal'Aran in Darkshore, Ordil'Aran in Ashenvale, Tethris Aran in Desolace.
+ A druid of the Emerald Circle keeps watch by the ruins; the wood around him is still sick.

## quarry
In the scarred vale where fire once fell on the forest, an infernal still burns,
elite and alone, walking among the scars.
= Immolatus, an elite infernal of Shatter Scar Vale.
+ Ten hours and a half at the least between one Immolatus and the next; sixteen at the most.
