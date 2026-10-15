---
zone: 1447   # Azshara
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: azshara-ravencrest
    tier: near
    area: Ravencrest Monument   # placed: the client's overlay: 70.6, 85.0, half-size 4.7 by 4.9
    hint_area: { x: 69.0, y: 83.0, r: 7 }
    danger: "Guarded (naga)"
    sources: "the Codex's ravencrest-monument page"
  - id: azshara-lake-mennar
    tier: off
    gestures: [DRINK, SIT]
    area: Lake Mennar   # placed: the client's overlay: 43.2, 80.1, half-size 5.7 by 6.7
    hint_area: { x: 43.0, y: 80.0, r: 6 }
    danger: "Perilous (the blue dragonkin round the lake, levels 50 to 53)"
    sources: "the WoWWiki archive's Lake Mennar page (the blue dragonflight, the lake's calm); the dump's spawns"
  - id: azshara-valormok
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 8586   # Haggrum Bloodfist, dump 22.5, 51.1
    found: target   # in the camp: only by speaking to him
    hint_area: { x: 22.0, y: 51.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and his words"
quarry:
  id: 6118   # Varo'then's Ghost
  sources: "the WoWWiki archive's Varo'then's Ghost page (Captain Varo'then, Queen Azshara's guard); the dump's path; the Codex's ravencrest-monument page"
---
## azshara-ravencrest
On the southern cliffs, the broken legs of a great statue still stand,
the rest of it scattered or under the sea.
It keeps the name of a lord who stood against the queen of this coast
and her demons, when the world was broken. Find what is left of him.
? Ravencrest Monument, on Azshara's southern cliffs.
= Ravencrest Monument. The naga hold the ruins around it.
+ Lord Kur'talos Ravencrest commanded the night elves' resistance in the War of the Ancients from Black Rook Hold: the queen's court was not the whole of her people.

## azshara-lake-mennar
In the south of the elves' old country, dragonkin of the blue flight hold the shores of a lake,
far from the cold north where their kind belongs.
Inside their ring, the lake itself is calm. Get through them, and refresh yourself at the water.
? Lake Mennar, in southern Azshara. Sit by the lake or make a drinking gesture there.
= Lake Mennar: blue dragonkin hold its shores, scalebanes, mageweavers and magelords, far from their flight's northern home.
+ Mazthoril's caves in Winterspring are another blue dragonflight refuge outside Northrend.

## azshara-valormok
In the Horde's camp in the elven wilds, an orc remembers when he and his brother
camped here alone, before there was any camp at all.
Ask him what he makes of it now.
? Valormok, in western Azshara. Speak to the orc who remembers the camp's beginning.
= Haggrum Bloodfist, at Valormok: 'I remember when my brother and I would camp alone in the Azshara wilderness. Look at it now.'
+ His brother, by the name, is Ag'tor Bloodfist, who has business enough for any traveller.

## quarry
Among the ruins of a shrine in the south-west,
a ghost walks in the armour of a queen's guard:
the captain who served the queen this land is named for, ten thousand years ago.
= Varo'then's Ghost: what is left of Captain Varo'then, who led Queen Azshara's guard in the War of the Ancients.
+ Farther east, Ravencrest's broken monument remembers a commander who opposed his queen. Azshara keeps the remains of both sides of that war.
