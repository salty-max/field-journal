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
    creature: 7324   # Simone Cantrell, Landscape Architect, dump 83.8, 79.8, at Ravenholdt Manor
    hint_area: { x: 82.8, y: 77.5, r: 7 }
    danger: "Quiet"
    sources: "the dump's spawns (Simone, Winstone Wolfe, Salome); the client's display tables (a night elf); the WoWWiki archive's Simone Cantrell and Salome pages"
quarry:
  id: 14222   # Araga
  sources: "the WoWWiki archive's Araga page (among the mountain lions); the dump's spawns; the WoWWiki archive's Araga page (her own skin: a slight mane, a striped tail); Petopia Classic (a tameable mountain lion)"
---
## alterac-mountains-simone
In the hills above the foothills, a manor hides from all who do not know the way,
a hall for those who work unseen.
And yet someone there works in plain sight, with a title to prove it:
Find the one who keeps the grounds of this most secret house.
? Ravenholdt Manor, up a mountain path north-west of Durnholde Keep.
= Simone Cantrell, a night elf, Landscape Architect to Ravenholdt Manor, hall of the Assassin's League.
+ Near the master stands Winstone Wolfe, whom the manor calls The Wolf; and a housecat, Salome, has the run of the place.

## quarry
Mountain lions own the southern hills of Alterac.
Among them, a lone female has a name of her own.
Search from the yetis' hills down toward the naze.
= Araga, a mountain lion of Alterac's southern hills, from west of the yetis' cave down to Gavin's Naze.
+ Her coat is her own: a slight mane and a striped tail, worn by no other cat.
