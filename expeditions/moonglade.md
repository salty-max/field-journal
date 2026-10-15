---
zone: 1450   # Moonglade
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: moonglade-flight-masters
    tier: near
    creature: 11800   # Silva Fil'naveth, dump 44.1, 45.2; Bunthen Plainswind (11798) beside her
    found: target   # by speaking to her
    hint_area: { x: 44.0, y: 46.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns and their words; the WoWWiki archive's Silva Fil'naveth and Bunthen Plainswind pages"
# no quarry: no rare creature lives here
---
## moonglade-flight-masters
In the druids' town by the sacred lake, an elf and a tauren keep flying beasts side by side,
and fly travellers to the capitals of their peoples for nothing.
Ask the elf for a flight, and hear what she tells most of those who ask.
? Nighthaven, by the lake, where the flying beasts wait. Speak to the elven flight master. You can keep your feet on the ground.
= Silva Fil'naveth and Bunthen Plainswind, flight masters of Nighthaven: 'You're not a druid!'
+ They fly druids alone, one way: she to Rut'theran, he to Thunder Bluff, and each sends you to the other for the other road.
