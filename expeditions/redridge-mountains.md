---
zone: 1433   # Redridge Mountains
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: redridge-mountains-near
    tier: near
    object: 121264   # dump 52.0, 44.7; Wowhead 52.0, 44.9
    hint_area: { x: 53.7, y: 41.1, r: 8 }
    danger: "Guarded (Blackrock orcs nearby)"
    sources: "quest 2282"
  - id: redridge-mountains-off
    tier: off
    object: 31   # dump 84.5, 46.8; Wowhead 84.3, 46.9
    hint_area: { x: 81.0, y: 44.8, r: 8 }
    danger: "Guarded (Morganth's gnolls)"
    sources: "quests 94, 249"
  - id: redridge-mountains-hidden
    tier: hidden
    where: { x: 28.4, y: 12.6, r: 2 }   # Corporal Keeshan, dump 28.4, 12.6; Wowhead 28.4, 12.6
    hint_area: { x: 29.7, y: 8.8, r: 8 }
    danger: "Perilous (Blackrock orcs)"
    sources: "object 1726's text (the poster); quest 219; Corporal Keeshan (creature 349) gives the spot"
    check: "the radius: Keeshan's place in the cave (dump 28.4, 12.6; Wowhead 28.4, 12.6), wide enough for the cave"
# quarry: the zone's own, in the hunts' pass
---
## redridge-mountains-near
Above the lake road, a mill stands abandoned,
and in it a locked box that no one lost:
an old thief keeps it there, to see which of his pupils can open it.
Find the box. You need not open it.
? Alther's Mill, just up off the road north-east of Lakeshire.
= Lucius's lockbox. Lakeshire has trained thieves 'for years', and this is their examination.
+ 'Did I forget to mention the orcs? I hear they have been nosing around up by the mill.' Lucius, to the pupil who comes back.

## redridge-mountains-off
Near a warlock's lonely tower, an old stone lion stands among the gnolls,
with a hollow at its base where a gem or a glyph might sit.
A rival mage once set his eye there.
Find the lion.
? In Redridge's north-east, near the Tower of Ilgalar.
= The old lion statue. Theocritus of the Tower of Azora watched Morganth through a glyph set at its base.
+ What he learned: Morganth sought the Scythe of Elune, and may have found it.

## redridge-mountains-hidden
A corporal dragged from the battle at the keep
is held in a cave of the black-rock orcs, north of the lake town,
just west of the pass to the burning lands.
Find where they keep him.
? Lakeshire's missing-poster says where: the Blackrock camp north of the town.
= Corporal Keeshan's cave. The poster in Lakeshire was right.
+ Most of his regiment was killed. He took a blow to the head, and woke a prisoner here.
