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
    tier: near
    reading: Toothgnasher's Skeleton
    object: 175683   # dump 74.3, 21.1; Wowhead's page alike
    hint_area: { x: 78.3, y: 21.6, r: 8 }
    danger: "Quiet"
    sources: "object 175683's text"
  - id: ironforge-tyrannistrasz
    tier: off
    reading: The Skull of Tyrannistrasz
    object: 175679   # dump 77.4, 27.6; Wowhead's page alike
    hint_area: { x: 81.3, y: 28.5, r: 8 }
    danger: "Quiet"
    sources: "objects 175679 and 175750's texts"
  - id: ironforge-mekkatorque
    tier: hidden
    creature: 7937   # High Tinker Mekkatorque, dump 68.8, 49.0; Wowhead 69.0, 49.0
    hint_area: { x: 70.1, y: 50.5, r: 4 }
    danger: "Quiet"
    sources: "the Codex's high-tinker-mekkatorque page"
# quarry: the zone's own, in the hunts' pass
---
## ironforge-toothgnasher
In the hall where the explorers keep their finds,
a scale model stands of a ram out of dwarven folklore,
too big and too tireless for any scholar to explain. Find it.
? The Hall of Explorers.
= Toothgnasher's skeleton, a scale replica.
+ 'The legendary ram was a wonder of Khaz Modan and the subject of many tales of dwarven folklore.'

## ironforge-tyrannistrasz
In the same hall, the skull of a red dragon of enormous size,
found in the marshes after the battle at the dragons' prison-fortress,
is said to have belonged to the elder consort of the Dragonqueen. Find it.
? The Hall of Explorers.
= The Skull of Tyrannistrasz.
+ Its remains were found in the Wetlands shortly after the Battle of Grim Batol, where the Dragonmaw had held Alexstrasza captive.

## ironforge-mekkatorque
In a quarter of the dwarves' city lent to a people without a home,
their leader works on, a long way from the city they lost
to their own weapon against the troggs, and to a friend who betrayed it. Find him.
? Tinker Town.
= High Tinker Gelbin Mekkatorque, leader of the gnomes.
+ 'A home borrowed from friends cannot settle the loss of Gnomeregan.' He once trusted Sicco Thermaplugg; now he asks adventurers to go down and kill him.
