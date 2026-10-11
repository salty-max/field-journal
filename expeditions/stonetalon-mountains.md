---
zone: 1442   # Stonetalon Mountains
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: stonetalon-mountains-near
    tier: near
    area: The Charred Vale   # placed: the client's overlay: 31.9, 67.0, half-size 7.5 by 10.9
    hint_area: { x: 33.0, y: 65.0, r: 12 }
    danger: "Guarded (harpies, fire elementals)"
    sources: "quests 1057, 6381"
  - id: stonetalon-mountains-off
    tier: off
    area: Boulderslide Ravine   # placed: the client's overlay: 64.9, 92.8, half-size 5.0 by 6.0
    hint_area: { x: 64.0, y: 90.0, r: 8 }
    danger: "Guarded (kobolds)"
    sources: "quest 6421"
  - id: stonetalon-mountains-hidden
    tier: hidden
    where: { x: 63.6, y: 40.0, r: 2 }   # Gerenzo Wrenchwhistle, dump 64.5, 40.3; Wowhead 62.8-64.2, 39.4-40.6
    hint_area: { x: 67.6, y: 39.6, r: 8 }
    danger: "Perilous (the Venture Co.)"
    sources: "quest 1096; Gerenzo Wrenchwhistle (creature 4202) gives the spot"
    check: "the spot's radius: Gerenzo walks (dump 64.5, 40.3; Wowhead 62.8-64.2, 39.4-40.6)"
# quarry: the zone's own, in the hunts' pass
---
## stonetalon-mountains-near
South of the peak, a vale was set afire
by an army of machines that came for the forest,
and harpies and angry fire hold it now.
Seeds were meant to be planted at its heart. Stand in the ash.
? South-west of Sun Rock Retreat, the land is burned.
= The Charred Vale. Keeper Albagorm, on the peak, calls it a travesty.
+ 'In time, the Venture Co. will pack up their buzz saws and axes, the angry fire spirits will calm, and the harpies will be pushed out by the land.' Tammra Windfield, of Sun Rock.

## stonetalon-mountains-off
South-east of the retreat on the rock, kobolds dig as if driven,
deep in a cave, after a rare crystal,
and there is a tension in the air near it
that the retreat can feel. Find the ravine.
? South-east of Sun Rock Retreat, toward the road down to the Barrens.
= Boulderslide Ravine. The kobolds mine resonite as if their lives hung on it.
+ Resonite carries a trace of Earthen magic: the kobolds may have dug down to one of the earthen, the Titans' makers of the land.

## stonetalon-mountains-hidden
High above the lake where the goblins work their machines,
near the great water wheel, their overseer watches the whole site,
his flesh rotting, metal and gears where his limbs were.
Climb to where he watches.
? Windshear Crag: look up from Cragpool Lake.
= Gerenzo Wrenchwhistle's post, above the water wheel. He sees everything from here, which is why so few reach him.
+ Ziz Fizziks, who wants his mechanical arm, can't see why anyone would cut off an arm to replace it with that when they could keep both and add a third: 'Gnomes, I tell you.'
