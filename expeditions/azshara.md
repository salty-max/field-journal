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
  - id: azshara-eldarath
    tier: off
    area: Ruins of Eldarath   # placed: the client's overlay: 36.7, 54.3, half-size 6.2 by 7.9
    hint_area: { x: 38.0, y: 52.0, r: 9 }
    danger: "Perilous (naga)"
    sources: "the Codex's ruins-of-eldarath page"
  - id: azshara-kimjael
    tier: off
    creature: 8420   # Kim'jael, dump 53.5, 21.8; Wowhead 53.4, 21.8
    hint_area: { x: 55.3, y: 23.5, r: 5 }
    danger: "Perilous (satyrs)"
    sources: "quest 3601"
  - id: azshara-arkkoroc
    tier: hidden
    creature: 6134   # Lord Arkkoroc, dump 77.1, 42.8; Wowhead 77.2, 42.8
    hint_area: { x: 75.9, y: 40.6, r: 5 }
    danger: "Perilous (his minions)"
    sources: "quests 3509, 3510, 3511"
  - id: azshara-hydraxis
    tier: hidden
    creature: 13278   # Duke Hydraxis, dump 79.3, 73.7; Wowhead 79.2, 73.6
    hint_area: { x: 81.6, y: 72.8, r: 5 }
    danger: "Quiet"
    sources: "the Codex's hydraxian-waterlords page"
  - id: azshara-talrendis
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 11548   # Loh'atu, dump 11.4, 78.2; Wowhead 11.4, 78.0
    hint_area: { x: 10.4, y: 80.5, r: 5 }
    danger: "Quiet"
    sources: "quests 5535, 5536"
  - id: azshara-valormok
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 8576   # Ag'tor Bloodfist, dump 22.3, 51.5; Wowhead 22.2, 51.4
    hint_area: { x: 23.8, y: 49.5, r: 5 }
    danger: "Quiet"
    sources: "quests 3504, 3505, 3506, 3507"
quarry:
  id: 8408
  sources: "quest 9362 (Archmage Xylem)"
---
## azshara-ravencrest
On the southern cliffs, the broken legs of a great statue still stand,
the rest of it scattered or under the sea.
It keeps the name of a lord who stood against the queen of this coast
and her demons, when the world was broken. Find what is left of him.
? Ravencrest Monument, on Azshara's southern cliffs.
= Ravencrest Monument. The naga hold the ruins around it.
+ Lord Kur'talos Ravencrest commanded the night elves' resistance in the War of the Ancients from Black Rook Hold: the queen's court was not the whole of her people.

## azshara-eldarath
On the eastern cliffs above the bay, a city of the old court
carved its learning into stone in its public places,
and most of it fell into the sea when the world broke. Walk what did not.
? The Ruins of Eldarath, above the Bay of Storms.
= The Ruins of Eldarath. Warlord Krellian's naga hold them now.
+ The Explorers' League wants rubbings of the inscriptions; the night elves avoid the place.

## azshara-kimjael
Among the satyrs of the northern hills, a goblin merchant
who signed on with treasure hunters from the elven kingdom
was called a little rat and left for dead.
Find him, still angry.
? The Legash Encampment, in the north of Azshara.
= Kim'jael, betrayed by the Thalassian expedition.
+ 'Kim'jael indeed!! Do you know what Kim'jael means to the Blood elves? Little rat... or something like that.'

## azshara-arkkoroc
At the water's edge on the eastern coast, in a temple of the sea,
a lesser god keeps his own court,
and knows the true names of demons, for a price.
Find him, and be discovered by no one else.
? The Temple of Arkkoran, on Azshara's east coast: begin at the water's edge.
= Lord Arkkoroc, in the Temple of Arkkoran.
+ He gave up the name of Razelikh the Defiler, once the head of the false goddess Hetaera was brought to him: 'She kills my children, mortal.'

## azshara-hydraxis
On an island in the southern bay lives a lord of the waters
at war with every other element, above all with fire,
and with the Firelord in his molten heart of the mountain. Find his island.
? An island in the south of the Bay of Storms.
= Duke Hydraxis, of the Hydraxian Waterlords.
+ They are not friends of mortals, but they make use of them against Ragnaros.

## azshara-talrendis
At the night elves' outpost on the forest's border, a stranger to them
keeps an oath to the Earth Mother to help them
against the satyrs and the restless spirits of the old court. Find him.
? Talrendis Point, on the border of Ashenvale.
= Loh'atu, sworn to the Earth Mother.
+ 'Her eyes, one dark and one light, travel across the skies always gazing down upon us.'

## azshara-valormok
In the Horde's camp on the western heights, an orc sent warriors
to guard an elven mage who promised treasure,
and she killed them all. He wants vengeance. Find him.
? Valormok.
= Ag'tor Bloodfist, of Valormok.
+ Belgrom Rockmaul, in Orgrimmar, trusted Magus Rimtori; when her head comes back to him he 'would give you a kingdom if it were in my power'.

## quarry
Among the ruins of the elves' old city, in the temple the naga have taken,
a warlord hides behind his guards
with a prismatic shell he covets above everything.
A mage in a tower atop the cliffs has seen it while scrying.
= Warlord Krellian, of the Spitelash naga. Archmage Xylem, in the tower, asks mages to bring the shell.
+ The shell has a strange aura: Xylem would have the one who brings it test what it can do.
