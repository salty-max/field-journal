---
zone: 1451   # Silithus
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: silithus-scarab-wall
    tier: off
    area: The Scarab Wall   # placed: the client's overlay: 28.9, 95.1, half-size 7.0 by 3.0
    hint_area: { x: 30.0, y: 92.0, r: 8 }
    danger: "Perilous (the silithid)"
    sources: "the Codex's the-scarab-wall and the-scepter-of-the-shifting-sands pages"
  - id: silithus-ortell
    tier: hidden
    where: { x: 67.2, y: 69.8, r: 1 }   # Hermit Ortell, dump 67.2, 69.8; Wowhead 67.0, 69.6
    hint_area: { x: 69.7, y: 69.6, r: 5 }
    danger: "Quiet"
    sources: "quests 8285, 8323"
# quarry: the zone's own, in the hunts' pass
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
