---
zone: 1442   # Stonetalon Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: stonetalon-mountains-sun-rock
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 11074   # Hgarth, Artisan Enchanter, dump 49.2, 57.2
    found: target   # in the town: only by speaking to him
    hint_area: { x: 48.0, y: 58.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and his words (the one whose skill exceeds his own)"
quarry:
  id: 4030   # Vengeful Ancient
  sources: "the WoWWiki archive's Vengeful Ancient page (a treant roaming the Charred Vale); the dump's spawn and respawn (5 to 8 hours)"
---
## stonetalon-mountains-sun-rock
In the Horde's retreat among the stone mountains, an enchanter teaches,
and he is as good as any in the world but one.
Those he has taught all he knows, he sends on to her. Ask him who she is.
? Sun Rock Retreat.
= Hgarth, Artisan Enchanter, at Sun Rock Retreat: 'There is only one whose skills exceed my own... She is Annora, and you may find her... in Uldaman.'
+ Annora keeps to the halls of Uldaman, under the Badlands, among its troggs and its dead: a strange home for the best enchanter in the world.

## quarry
In the vale the fire took, charred ancients of the forest still walk among the burnt trunks,
and one of them is more than charred: he is vengeful.
He is back five to eight hours after he falls.
= The Vengeful Ancient, a treant of the Charred Vale, among its charred ancients.
+ The vale burns still: flame spirits and burning destroyers roam it, and the ancients walk among them.
