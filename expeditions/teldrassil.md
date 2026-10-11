---
zone: 1438   # Teldrassil
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: teldrassil-feralas-history
    tier: near
    object: 142958   # dump 55.2, 91.5; Wowhead 55.3, 91.4
    hint_area: { x: 52.1, y: 94.1, r: 8 }
    danger: "Quiet"
    sources: "quest 2940"
  - id: teldrassil-dreamcatcher
    tier: off
    gestures: [SEARCH, LOOK]
    object: 126158   # dump 68.0, 59.7; Wowhead 68.0, 59.6
    hint_area: { x: 69.9, y: 63.2, r: 8 }
    danger: "Guarded (the Gnarlpine furbolgs)"
    sources: "quest 2438"
  - id: teldrassil-oracle-glade
    tier: hidden
    gestures: [BOW, KNEEL]
    area: The Oracle Glade   # placed: the client's overlay: 37.9, 36.3, half-size 3.0 by 10.9
    hint_area: { x: 39.5, y: 34.0, r: 12 }
    danger: "Guarded (the Bloodfeather harpies)"
    sources: "quests 934, 937"
# quarry: the zone's own, in the hunts' pass
---
## teldrassil-feralas-history
Where the boats come in below the great tree,
a book lies unopened so long its covers have worn
and its pages yellowed: the history of a far forest.
Find it, and ask before you borrow it.
? Rut'theran Village, at the tree's foot, keeps an old book by the docks.
= Feralas: A History. Daryn Lightwind owns it, and will lend it, for a favour first.
+ Someone in Feralas, Troyas, has been looking for exactly this book.

## teldrassil-dreamcatcher
In a village the corrupted furbolgs took,
a dresser still holds what its owner could not go back for:
a charm that draws on the Emerald Dream
and lends luck to whoever carries it. It is somewhere in the drawers.
? Starbreeze Village, east of Dolanaar, was once a tranquil place; one house kept its furniture.
= Tallonkai Swiftroot's dresser. The dreamcatcher in it is a gift 'given only to few'.
+ It came from Gaerolas Talvethren, warden of the druids in the Ban'ethil Barrow Den.

## teldrassil-oracle-glade
The first and most powerful of the moonwells
lies to the north-west, under the boughs of a tree that answers.
Sentinels hold its glade against the harpies,
and the last runner it sent to the city never arrived.
Come before the tree as one comes before the wise.
? North of Darnassus, the Sentinels are fighting harpies around an old tree that speaks.
= The Oracle Glade, and the oldest moonwell of the new tree.
+ Teldrassil grew without the dragons' blessing: Nozdormu refused the Arch Druid for his arrogance, Alexstrasza with him, and the tree's growth has been flawed and unpredictable since.
