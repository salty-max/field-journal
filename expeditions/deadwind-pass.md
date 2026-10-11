---
zone: 1430   # Deadwind Pass
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: deadwind-pass-karazhan
    tier: off
    area: Karazhan   # placed: the client's overlay: 42.7, 68.9, half-size 9.2 by 12.0
    hint_area: { x: 44.0, y: 66.0, r: 13 }
    danger: "Perilous (the tower's dead)"
    sources: "objects 175745 (The Dark Portal and the Fall of Stormwind) and 175740 (The Last Guardian)"
# no quarry: no rare creature lives here
---
## deadwind-pass-karazhan
In a pass where nothing grows, a tower stands where a Guardian lost himself:
a demon had hidden in him before he was born.
A knight of the old blood and the Guardian's own apprentice climbed to him at last,
and set his good spirit wandering. Find the tower.
? Karazhan, at the southern end of Deadwind Pass.
= Karazhan, Medivh's tower.
+ Lothar and the young Khadgar stormed it and killed Medivh's body, banishing Sargeras's spirit, and freed the Guardian's own to wander the astral plane for many years to come.
