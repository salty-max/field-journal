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
    gestures: [AMAZE, AWE, WHOA, GASP]
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
The dwarves still tell of a ram of Khaz Modan,
too big for any scholar to account for and tireless past all reason.
In their city his likeness stands, bones and all, built to scale.
Get beneath him, and be as impressed as the tellers were.
? The Hall of Explorers. Beneath the great skeleton, show amazement or gasp.
= Toothgnasher's skeleton, a scale replica.
+ 'The legendary ram was a wonder of Khaz Modan and the subject of many tales of dwarven folklore.'

## ironforge-tyrannistrasz
After Grim Batol fell, the Wetlands gave up the remains of something vast,
and the dwarves brought them home for their explorers to show.
The tale goes that, alive, it flew at a queen's side,
the eldest of her consorts. Learn whose it was.
? The Hall of Explorers. Read the inscription beside the skull.
= The Skull of Tyrannistrasz.
+ Its remains were found in the Wetlands shortly after the Battle of Grim Batol, where the Dragonmaw had held Alexstrasza captive.

## ironforge-great-forge
At the heart of the dwarves' city, by the great forge that gives it its name,
the forge's keeper waits for smiths good enough to hear what he has to say:
that a smith must choose one way, and never the other. Ask him.
? The Great Forge, at the heart of Ironforge. Speak to the forge's keeper. You do not need to learn a specialization.
= Myolor Sunderfury, keeper of the Great Forge: 'The way of the weaponsmith or the art of the armorsmith.'
+ 'Be warned, when you have chosen to dedicate yourself to a path, there is no going back. The discipline each path requires leaves no room for hybrids.'
