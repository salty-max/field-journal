---
zone: 1435   # Swamp of Sorrows
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: swamp-of-sorrows-stonard
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: The New Horde
    object: 175752   # dump 47.6, 55.0; Wowhead's page alike
    hint_area: { x: 51.2, y: 53.2, r: 8 }
    danger: "Quiet"
    sources: "object 175752's text"
quarry:
  id: 14445   # Lord Captain Wyrmak
  sources: "the WoWWiki archive's Lord Captain Wyrmak and Sorrowmurk pages (the dragonspawn, the acid breath); the dump's path"
---
## swamp-of-sorrows-stonard
In the stone fortress above the mire, seek a child's name that meant a lifetime in chains.
A warden chose it for the orphan he raised.
The story did not end as he intended.
? Stonard.
= The New Horde, in Stonard: Aedelas Blackmoore and the orphan he called Thrall.
+ Doomhammer fell freeing one of the camps; Thrall took up his warhammer and his black plate, and became warchief of the Horde.

## quarry
East of the sunken temple, dragonspawn hold the Sorrowmurk,
captains and elders among them, and above the captains walks one with a lord's title.
He keeps a long round, from the Pool of Tears down the marsh's eastern edge and back.
= Lord Captain Wyrmak, an elite dragonspawn, walking the Sorrowmurk and the shores of the Pool of Tears.
+ His breath is acid, and it builds on you, up to ten times over if you stay in it.
