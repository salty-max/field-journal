---
zone: 1443   # Desolace
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: desolace-tethris-aran
    tier: off
    gestures: [PONDER, THINK, SIGH, MOURN]
    area: Tethris Aran   # placed: the client's overlay: 54.4, 12.4, half-size 5.0 by 4.9
    hint_area: { x: 54.5, y: 13.0, r: 5 }
    danger: "Guarded (basilisks, scorpids and starving bonepaws, levels 30 to 32)"
    sources: "the WoWWiki archive's Tethris Aran and Sargeron pages; the dump's spawns"
  - id: desolace-shadowbreak
    tier: hidden
    gestures: [PET, PAT, COMFORT, SOOTHE]
    creature: 13837   # the Captured Stallions, dump 79.5-79.9, 79.4-79.8, beside the Burning Blade Nightmares (13836)
    hint_area: { x: 80.0, y: 79.0, r: 4 }
    danger: "Perilous (the Burning Blade's summoners, invokers and ley hunters, levels 38 to 40)"
    sources: "the WoWWiki archive's Shadowbreak Ravine and Captured Stallion pages; the dump's spawns"
quarry:
  id: 14227   # Hissperak
  sources: "the dump's spawns and kind (a basilisk); Wowhead's sightings by the Kodo Graveyard and toward the Valley of Spears"
---
## desolace-tethris-aran
North of the Burning Blade's fortress, the stones of an elven town lie scattered in the dust.
No elf has lived there since the world broke;
the beasts of the waste have it now. Give a thought to those who built these walls.
? Tethris Aran, in the north of Desolace.
= Tethris Aran: the ruins of a night elf town in the north of Desolace; only beasts live there now.
+ Further east, the satyrs hold another such ruin, and have named it Sargeron, for their master.

## desolace-shadowbreak
In a ravine hidden in the south-eastern mountains, among mushrooms as tall as trees,
the Burning Blade work a summoning circle hung with chains, and keep a stable.
Some of the horses in it are still horses. Be kind to them.
? Shadowbreak Ravine, hidden in Desolace's south-eastern mountains.
= Shadowbreak Ravine: the Burning Blade's hidden camp, its chained circle, its demon nightmares, and two captured stallions in the stable beside them.
+ Where the stallions came from, nobody knows; what the cult means to make of them, the nightmares beside them suggest.

## quarry
North of the graveyard where the kodos go to die,
a basilisk hunts the dust.
Seek it beyond the bones, where the dead herds give way to open waste.
= Hissperak, a basilisk seen north of the Kodo Graveyard.
+ It has also been met west toward the Valley of Spears. A search confined to the bones can miss it altogether.
