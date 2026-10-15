---
zone: 1412   # Mulgore
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: mulgore-rolling-plains
    tier: off
    gestures: [PEER, LOOK, GAZE, STARE]
    area: The Rolling Plains   # placed: the client's overlay: 62.9, 67.7
    hint_area: { x: 60.5, y: 65.0, r: 7 }
    danger: "Quiet (prairie wolves, and centaur outriders now and then)"
    sources: "the WoWWiki archive's The Rolling Plains and The Golden Plains pages"
  - id: mulgore-three-hammers
    tier: hidden
    reading: War of the Three Hammers
    object: 175739   # dump 31.6, 49.4; Wowhead 31.6, 49.4
    hint_area: { x: 29.5, y: 52.8, r: 8 }
    danger: "Guarded (the Bael'dun dwarves)"
    sources: "object 175739's text; the WoWWiki archive's Bael'dun Digsite page (Lands of Mystery, 2005)"
quarry:
  id: 5807   # The Rake
  sources: "the WoWWiki archive's The Rake and The Golden Plains pages (his speed, the hunters' pet, the hunting grounds); the dump's spawns"
---
## mulgore-rolling-plains
In the south-east of the plains, where the grass rolls down toward the dry country,
wolves and kodo, striders and cougars share the open ground,
and now and then riders from beyond the border:
the only place they have ever got into the tauren's land. Keep an eye out for them.
? South-east of Bloodhoof Village, toward the Barrens: the grass that rolls to the border. Peer across the plains. There is no need to wait for the riders.
= The Rolling Plains: the one part of Mulgore the centaurs' outriders have broken into.
+ North, beyond Bloodhoof Village, the Golden Plains around the bluff are the most treasured of the tauren's hunting grounds.

## mulgore-three-hammers
In the dwarves' quarry in the western cliffs, seek their own account of a war.
It begins with three claimants to a throne
and ends with two kings beside a mountain road.
? The Bael'dun Digsite, in Mulgore's western cliffs. Read the dwarves' account of their three rival clans.
= War of the Three Hammers, at the Bael'dun Digsite: an outpost of the four hundred and fifty dwarves digging at Bael Modan. The tauren see the dig as an affront to the Earth Mother.
+ Brann Bronzebeard, it is told, visited the dig and went on to Thunder Bluff, to propose that tauren work beside the dwarves so that the land would be cared for.

## quarry
In the golden grass east of the bluff, a lion hunts alone,
quicker with his claws than the other cats of the plains.
The bluff's hunters would sooner tame him than skin him.
= The Rake, a lion of the Golden Plains. He strikes faster than nearly any beast a hunter can tame, which made him one of the commonest companions of the land.
+ He has been met nowhere outside the Golden Plains, the tauren's most treasured hunting grounds.
