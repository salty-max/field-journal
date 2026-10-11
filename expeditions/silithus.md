---
zone: 1451   # Silithus
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: silithus-scarab-wall
    tier: off
    area: The Scarab Wall   # placed: the client's overlay: 28.9, 95.1, half-size 7.0 by 3.0
    hint_area: { x: 30.0, y: 92.0, r: 8 }
    danger: "Perilous (the silithid)"
    sources: "the Codex's the-scarab-wall and the-scepter-of-the-shifting-sands pages"
  - id: silithus-ortell
    tier: hidden
    creature: 15194   # Hermit Ortell, dump 67.2, 69.8; Wowhead 67.0, 69.6
    hint_area: { x: 69.7, y: 69.6, r: 5 }
    danger: "Quiet"
    sources: "quests 8285, 8323"
quarry:
  id: 15541
  sources: "quest 8740 (the tactical briefing, Windcaller Proudhorn)"
---
## silithus-scarab-wall
At the southern end of the yellow desert stands a wall
raised when the night elves could not win their war against the insects alone,
and a dragon of time sealed it. A gong hangs before it.
Find the wall, and leave the gong alone.
? The Scarab Wall, at the southern edge of Silithus.
= The Scarab Wall, and Ahn'Qiraj behind it.
+ A thousand years ago the qiraji and their silithid swarms came out of Ahn'Qiraj and fell on Kalimdor; the bronze dragon Anachronos made the Scepter of the Shifting Sands to seal them in.

## silithus-ortell
In the mountains south of a ruined village, a man who left
the cult that worships the old gods lives alone,
decoding their bulletins to learn whether they still hunt him. Find him.
? The mountains south of Southwind Village, in Silithus's east.
= Hermit Ortell, deserter of the Twilight's Hammer.
+ 'I see you're familiar with my old organization.' His old sect circulates an encoded bulletin every month, the True Believer.

## quarry
Mounted cultists of the Twilight's Hammer ride the sands
beyond the reach of Cenarion Hold, picking off its patrols and caravans.
Their leader is a terrible warrior.
They ride a long road through the sands, east and south of the Hold.
= Twilight Marauder Morna. Windcaller Proudhorn, at Cenarion Hold, wants Morna and the riders defeated.
+ They were costing the Hold's patrols more lives than it could accept.
