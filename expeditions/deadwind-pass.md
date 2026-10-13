---
zone: 1430   # Deadwind Pass
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: deadwind-pass-deadmans-crossing
    tier: near
    gestures: [SHIVER, SCARED, COWER, FLEE]
    area: Deadman's Crossing   # placed: its signpost, 'Turn Back!' (object 177186), dump 35.5, 35.1
    anchor: { object: 177186 }   # what places its hint: the area's overlay is the gorge's too
    hint_area: { x: 37.0, y: 36.0, r: 5 }
    danger: "Quiet on the road"
    sources: "the dump's objects (the signpost's 'Turn Back!'); the WoWWiki archive's Deadman's Crossing page (the hangman's tree, 'Abandon hope')"
  - id: deadwind-pass-karazhan
    tier: off
    area: Karazhan   # placed: the client's overlay: 42.7, 68.9, half-size 9.2 by 12.0
    hint_area: { x: 44.0, y: 66.0, r: 13 }
    danger: "Perilous (the tower's dead)"
    sources: "objects 175745 (The Dark Portal and the Fall of Stormwind) and 175740 (The Last Guardian)"
# no quarry: no rare creature lives here
---
## deadwind-pass-deadmans-crossing
Where the road from the dark wood meets the way down to a dead tower,
a tree holds two hanged men, and a signpost speaks plainly to travellers.
Take its advice, or don't. But show it what its warning does to you.
? Deadman's Crossing, where the road enters Deadwind Pass from Duskwood.
= Deadman's Crossing: a hangman's tree with its pair of corpses, and a signpost that says 'Turn Back!'
+ Its other arm is grimmer: 'Abandon hope, all ye who enter here.' And yet the road itself is safe enough, for those who keep to it.

## deadwind-pass-karazhan
In a pass where nothing grows, a tower stands where a Guardian lost himself:
a demon had hidden in him before he was born.
A knight of the old blood and the Guardian's own apprentice climbed to him at last,
and set his good spirit wandering. Find the tower.
? Karazhan, at the southern end of Deadwind Pass.
= Karazhan, Medivh's tower.
+ Lothar and the young Khadgar stormed it and killed Medivh's body, banishing Sargeras's spirit, and freed the Guardian's own to wander the astral plane for many years to come.
