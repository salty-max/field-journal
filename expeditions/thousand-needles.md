---
zone: 1441   # Thousand Needles
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: thousand-needles-near
    tier: near
    area: Tahonda Ruins   # placed: the Saltstone Gazers, dump 71.2-77.0, 87.9-90.7
    hint_area: { x: 74.0, y: 86.0, r: 10 }
    danger: "Quiet"
    sources: "the wiki's Tahonda Ruins (in Classic, the Saltstone basilisks)"
    check: "the hint's circle (from the Saltstone Gazers' spawns, 71-77, 87-91) and a margin; if neither holds, Rizzle's Unguarded Plans (object 20805, 77.2, 77.4, quest 1190) take this place"
  - id: thousand-needles-off
    tier: off
    object: 19861   # dump 30.7, 24.3; Wowhead 30.7, 24.4
    hint_area: { x: 31.3, y: 28.3, r: 8 }
    danger: "Guarded (quilboar)"
    sources: "quests 1100, 1101; the journal (item 5790)"
  - id: thousand-needles-hidden
    tier: hidden
    area: The Weathered Nook   # placed: Dorn Plainstalker, dump 53.9, 41.5; Wowhead 53.8, 41.4
    hint_area: { x: 50.6, y: 42.6, r: 7 }
    danger: "Quiet"
    sources: "quests 1149-1152; Dorn Plainstalker (creature 2986) places the hint"
# quarry: the zone's own, in the hunts' pass
---
## thousand-needles-near
On the salt flats where the racers run,
a tauren village came to ruin long ago
and slipped beneath the sand. Basilisks keep it now.
Find what is left of it.
? The south of the Shimmering Flats, toward the path to Tanaris.
= The Tahonda Ruins. Nobody has written down who lived here.
+ (to find: no text of the original game tells of Tahonda)

## thousand-needles-off
Near the boar men's bramble, at the needles' northern edge,
a dwarf of the Explorers' League lies dead beside his journal.
He went looking for the bones of a fallen god,
and the boar men took him instead. Find his journal.
? In Thousand Needles' north-west, near the Great Lift and the thorns of the Kraul.
= Henrig Lonebrow's journal. Its last pages were written in a cell in Razorfen Kraul, beside a dying night elf druid.
+ The druid, Heralath, told him the great boar skull marks where Agamaggan fell fighting the Burning Legion ten thousand years ago, and that thorns grow where his blood sank into the earth.

## thousand-needles-hidden
On the canyon's northern wall a cave hides above the road,
reached by a path most travellers never see.
A tauren there tests whoever finds him,
and his first test is a step off the planks. Find his nook.
? North-east of Freewind Post, high on the canyon's northern wall.
= The Weathered Nook, where Dorn Plainstalker tests faith, endurance, strength and lore.
+ 'It does not matter what you believe sometimes. It is just important that you believe in something.' Dorn, after the leap.
