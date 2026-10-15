---
zone: 1427   # Searing Gorge
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: searing-gorge-stonewrought-pass
    tier: off
    area: Stonewrought Pass   # placed: the gate at its southern end (object 150137), dump 78.7, 17.2
    anchor: { object: 150137 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 76.0, y: 19.0, r: 5 }
    danger: "Guarded (glassweb spiders, level 43), and the gate is locked"
    sources: "quest 3801's text (Franclorn Forgewright and the stonewrought method); the WoWWiki archive's Stonewrought Pass and Franclorn Forgewright pages"
  - id: searing-gorge-blackchar
    tier: hidden
    gestures: [STARE, GASP, SURPRISED, AMAZE, LOOK, GAZE, PEER]
    area: Blackchar Cave   # placed: the client's overlay: 23.0, 73.4; its mouth by Elder Ironband's Lunar Festival spot, dump 21.5, 79.0
    hint_area: { x: 22.5, y: 77.0, r: 5 }
    danger: "Perilous (lava spiders and fire elementals, levels 46 to 48)"
    sources: "the WoWWiki archive's Blackchar Cave page (the face on the minimap); Engadget, 'A face in Searing Gorge' (2007); the dump's Lunar Festival spawn"
quarry:
  id: 8280   # Shleipnarr
  sources: "https://www.wowhead.com/classic/npc=8280/shleipnarr (period accounts of the riderless felsteed, Mana Burn and Terrify); the pinned dump's path and creature_ai_scripts (13321 Mana Burn, 7399 Terrify); the dump's loot (Long Tail Hair, Fine Loose Hair)"
---
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
Go there and study your map, not the rock:
something in the mountains is staring back.
? Blackchar Cave, at the Searing Gorge's south-western edge. Look at the face on your minimap while standing by the cave.
= Blackchar Cave, sealed. And in the mountains above it, on the minimap, is what can only be a face.
+ The cave keeps its seal all year. Only at the Lunar Festival does an elder of Ironforge come to stand at its mouth.

## quarry
A demon's horse runs loose in the old dig south-east of the Cauldron.
Fire burns at its hooves,
but there is no rider on its back.
= Shleipnarr, a felsteed with no warlock to ride it, roaming the Grimesilt Dig Site.
+ What it leaves behind is horsehair, long hair from the tail and finer loose strands: a demon, and still a horse.
