---
zone: 1455   # Ironforge
home: alliance   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: ironforge-toothgnasher
    tier: off
    reading: Toothgnasher's Skeleton
    object: 175683   # dump 74.3, 21.1; Wowhead's page alike
    hint_area: { x: 78.3, y: 21.6, r: 8 }
    danger: "Quiet"
    sources: "object 175683's text"
  - id: ironforge-tyrannistrasz
    tier: hidden
    reading: The Skull of Tyrannistrasz
    object: 175679   # dump 77.4, 27.6; Wowhead's page alike
    hint_area: { x: 81.3, y: 28.5, r: 8 }
    danger: "Quiet"
    sources: "objects 175679 and 175750's texts"
  - id: ironforge-great-forge
    tier: near
    creature: 11145   # Myolor Sunderfury, dump 51.7, 41.4, by the Great Forge
    found: target   # in the city: only by speaking to him
    hint_area: { x: 51.5, y: 42.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and his words"
# no quarry: a capital has riddles alone
---
## ironforge-toothgnasher
In the hall where the explorers keep their finds,
a scale model stands of a ram out of dwarven folklore,
too big and too tireless for any scholar to explain. Find it.
? The Hall of Explorers.
= Toothgnasher's skeleton, a scale replica.
+ 'The legendary ram was a wonder of Khaz Modan and the subject of many tales of dwarven folklore.'

## ironforge-tyrannistrasz
In the hall where the explorers display their finds, seek an enormous red dragon's skull.
Its label remembers the Dragonqueen's elder consort
and a battle fought beyond the pass to the north.
? The Hall of Explorers.
= The Skull of Tyrannistrasz.
+ Its remains were found in the Wetlands shortly after the Battle of Grim Batol, where the Dragonmaw had held Alexstrasza captive.

## ironforge-great-forge
At the heart of the dwarves' city, by the great forge that gives it its name,
the forge's keeper waits for smiths good enough to hear what he has to say:
that a smith must choose one way, and never the other. Ask him.
? The Great Forge, at the heart of Ironforge.
= Myolor Sunderfury, keeper of the Great Forge: 'The way of the weaponsmith or the art of the armorsmith.'
+ 'Be warned, when you have chosen to dedicate yourself to a path, there is no going back. The discipline each path requires leaves no room for hybrids.'
