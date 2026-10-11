---
zone: 1441   # Thousand Needles
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: thousand-needles-raceway
    tier: near
    gestures: [CHEER, APPLAUD]
    area: Mirage Raceway   # placed: Pozzik (creature 4630), dump 80.2, 75.9; Trackmaster Zherin, 81.6, 78.0
    anchor: { creature: 4630 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 79.0, y: 77.5, r: 7 }
    danger: "Quiet"
    sources: "quests 1186, 1190, 1120"
  - id: thousand-needles-lonebrow
    tier: off
    object: 19861   # dump 30.7, 24.3; Wowhead 30.7, 24.4
    hint_area: { x: 32.4, y: 20.7, r: 8 }
    danger: "Guarded (quilboar)"
    sources: "quests 1100, 1101; the journal (item 5790)"
  - id: thousand-needles-weathered-nook
    tier: hidden
    area: The Weathered Nook   # placed: Dorn Plainstalker, dump 53.9, 41.5; Wowhead 53.8, 41.4
    anchor: { creature: 2986 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 54.7, y: 38.1, r: 7 }
    danger: "Quiet"
    sources: "quests 1149-1152; Dorn Plainstalker (creature 2986) places the hint"
  - id: thousand-needles-freewind
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [COMFORT, SOOTHE]
    creature: 10645   # Thalia Amberhide, dump 46.0, 51.6; Wowhead 46.0, 51.6
    hint_area: { x: 47.5, y: 53.6, r: 5 }
    danger: "Quiet"
    sources: "quest 4904"
# quarry: the zone's own, in the hunts' pass
---
## thousand-needles-raceway
On the salt flats, gnomes and goblins race their machines,
each crew in its own pit, each spying on the other,
and the racers keep needing new pilots.
Find the track, and be the crowd they race for.
? The Mirage Raceway, on the Shimmering Flats.
= The Mirage Raceway. The Brassbolts race for the gnomes, Pozzik's crew for the goblins.
+ Pozzik's pilot, Razzeric, is the eighteenth; Kravel Koalbeard pays travellers to bring one pit crew or the other a Fool's Stout before the race.

## thousand-needles-lonebrow
Near the boar men's bramble, at the needles' northern edge,
a dwarf of the Explorers' League lies dead beside his journal.
He went looking for the bones of a fallen god,
and the boar men took him instead. Find his journal.
? In Thousand Needles' north-west, near the Great Lift and the thorns of the Kraul.
= Henrig Lonebrow's journal. Its last pages were written in a cell in Razorfen Kraul, beside a dying night elf druid.
+ The druid, Heralath, told him the great boar skull marks where Agamaggan fell fighting the Burning Legion ten thousand years ago, and that thorns grow where his blood sank into the earth.

## thousand-needles-weathered-nook
On the canyon's northern wall a cave hides above the road,
reached by a path most travellers never see.
A tauren there tests whoever finds him,
and his first test is a step off the planks. Find his nook.
? North-east of Freewind Post, high on the canyon's northern wall.
= The Weathered Nook, where Dorn Plainstalker tests faith, endurance, strength and lore.
+ 'It does not matter what you believe sometimes. It is just important that you believe in something.' Dorn, after the leap.

## thousand-needles-freewind
On the high mesas of the needles' outpost, a tauren waits
for the one she loves, carried off by a Grimtotem she refused,
whose brother died trying to stop him.
Find her, and ease her waiting.
? Freewind Post.
= Thalia Amberhide. Lakota Windsong is held at the Darkcloud Pinnacle.
+ 'Deep in my bones I knew that she would find her way back to me.'
