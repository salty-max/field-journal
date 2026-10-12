---
zone: 1427   # Searing Gorge
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: searing-gorge-cauldron
    tier: near
    area: The Cauldron   # placed: the client's overlay: 46.2, 49.4, half-size 14.7 by 10.5
    hint_area: { x: 44.0, y: 51.0, r: 13 }
    danger: "Perilous (Dark Irons, golems)"
    sources: "the Codex's the-cauldron page"
  - id: searing-gorge-stonewrought-pass
    tier: off
    area: Stonewrought Pass   # placed: the gate at its southern end (object 150137), dump 78.7, 17.2
    anchor: { object: 150137 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 76.0, y: 19.0, r: 5 }
    danger: "Guarded (glassweb spiders, level 43); and the gate is locked"
    sources: "quest 3801's text (Franclorn Forgewright and the stonewrought method); the WoWWiki archive's Stonewrought Pass and Franclorn Forgewright pages"
  - id: searing-gorge-blackchar
    tier: hidden
    gestures: [STARE, GASP, SURPRISED, AMAZE]
    area: Blackchar Cave   # placed: the client's overlay: 23.0, 73.4; its mouth by Elder Ironband's Lunar Festival spot, dump 21.5, 79.0
    hint_area: { x: 22.5, y: 77.0, r: 5 }
    danger: "Perilous (lava spiders and fire elementals, levels 46 to 48)"
    sources: "the WoWWiki archive's Blackchar Cave page (the face on the minimap); Engadget, 'A face in Searing Gorge' (2007); the dump's Lunar Festival spawn"
quarry:
  id: 8280   # Shleipnarr
  sources: "the WoWWiki archive's Shleipnarr page (a felsteed); the dump's path and respawn (32 to 48 hours)"
---
## searing-gorge-cauldron
In a basin of ash, dwarves of dark iron work a great pit
with golems and slaves, in heat that drives the slaves mad,
so mad they strike at those who would free them. Look down into it.
? The Cauldron, in the middle of the Searing Gorge.
= The Cauldron, the Dark Irons' great mining pit.
+ Beneath it, Overseer Maltorius commands the Slag Pit, back with the masters he once left.

## searing-gorge-stonewrought-pass
North of the valley of dust and fire, a tunnel runs under the mountains to the lake country,
shut at this end by an iron gate, its lever just beside it.
The way of building that made the pass was a Dark Iron's invention,
and so was the great dam on the lake beyond. Get inside.
? The north end of Dustfire Valley, in the Searing Gorge's north-east.
= Stonewrought Pass: stonewrought, like the dam on Loch Modan, after the method of Franclorn Forgewright, a Dark Iron architect.
+ His ghost, deep in Blackrock Mountain, says so himself: 'You have undoubtedly passed through or stood upon one of my creations.'

## searing-gorge-blackchar
In the gorge's south-west, a cave is sealed shut under the mountains,
and there is nothing at its mouth but black rock.
Stand there and study your map, not the rock:
something in the mountains is staring back.
? Blackchar Cave, at the Searing Gorge's south-western edge; what you want is on your minimap.
= Blackchar Cave, sealed; and in the mountains above it, on the minimap, what can only be a face.
+ The cave keeps its seal all year; only at the Lunar Festival does an elder of Ironforge come to stand at its mouth.

## quarry
A demon's horse runs loose in the old dig south-east of the Cauldron,
burning as it goes, with no rider on its back.
It is seen once in two days, if that.
= Shleipnarr, a felsteed with no warlock to ride it, roaming the Grimesilt Dig Site.
+ Slain, it takes a day and a half at the least to come back, and two days at the most.
