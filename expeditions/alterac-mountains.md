---
zone: 1416   # Alterac Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: alterac-mountains-simone
    tier: hidden
    gestures: [SNEAK, SHIFTY]
    creature: 7324   # Simone Cantrell, Landscape Architect, dump 83.8, 79.8, at Ravenholdt Manor
    hint_area: { x: 82.8, y: 77.5, r: 7 }
    danger: "Quiet"
    sources: "the dump's spawns (Simone, Winstone Wolfe, Salome); the client's display tables (a night elf); the WoWWiki archive's Simone Cantrell and Salome pages"
quarry:
  id: 14222   # Araga
  sources: "the WoWWiki archive's Araga page (among the mountain lions; among the rarest cats); the dump's spawn and respawn (24 to 36 hours)"
---
## alterac-mountains-simone
In the hills above the foothills, a manor hides from all who do not know the way,
a hall for those who work unseen.
And yet someone there works in plain sight, with a title to prove it:
find who keeps the grounds, and arrive as the manor's guests do.
? Ravenholdt Manor, up a mountain path north-west of Durnholde Keep.
= Simone Cantrell, a night elf, Landscape Architect to Ravenholdt Manor, hall of the Assassin's League.
+ Near the master stands Winstone Wolfe, whom the manor calls The Wolf; and a housecat, Salome, has the run of the place.

## quarry
Mountain lions own the southern hills of Alterac, and one of them has a name.
She looks like any of the others, and is seen by almost no one:
killed, she takes a day at the least to come back, and a day and a half at the most.
= Araga, a mountain lion of Alterac's southern hills, from west of the yetis' cave down to Gavin's Naze.
+ Of all the great cats of these lands, she may be the rarest.
