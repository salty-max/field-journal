---
zone: 1433   # Redridge Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: redridge-mountains-lockbox
    tier: near
    gestures: [SNEAK]
    object: 121264   # dump 52.0, 44.7; Wowhead 52.0, 44.9
    hint_area: { x: 55.0, y: 42.1, r: 8 }
    danger: "Guarded (Blackrock orcs nearby)"
    sources: "quest 2282"
  - id: redridge-mountains-lion-statue
    tier: off
    object: 31   # dump 84.5, 46.8; Wowhead 84.3, 46.9
    hint_area: { x: 88.4, y: 45.8, r: 8 }
    danger: "Guarded (Morganth's gnolls)"
    sources: "quests 94, 249"
  - id: redridge-mountains-keeshan
    tier: hidden
    creature: 349   # Corporal Keeshan, dump 28.4, 12.6; Wowhead 28.4, 12.6
    hint_area: { x: 31.4, y: 12.6, r: 6 }
    danger: "Perilous (Blackrock orcs)"
    sources: "object 1726's text; quest 219"
  - id: redridge-mountains-lakeshire
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: "Missing: Corporal Keeshan"
    object: 1726   # dump 26.5, 46.4; Wowhead 26.4, 46.6
    hint_area: { x: 22.5, y: 45.8, r: 8 }
    danger: "Quiet"
    sources: "object 1726's text"
# quarry: the zone's own, in the hunts' pass
---
## redridge-mountains-lockbox
Above the lake road, a mill stands abandoned,
and in it a locked box that no one lost:
an old thief keeps it there, to see which of his pupils can reach it.
Go as his pupils go.
? Alther's Mill, just up off the road north-east of Lakeshire; thieves are not seen coming.
= Lucius's lockbox. Lakeshire has trained thieves 'for years', and this is their examination.
+ 'Did I forget to mention the orcs? I hear they have been nosing around up by the mill.' Lucius, to the pupil who comes back.

## redridge-mountains-lion-statue
Near a warlock's lonely tower, an old stone lion stands among the gnolls,
with a hollow at its base where a gem or a glyph might sit.
A rival mage once set his eye there.
Find the lion.
? In Redridge's north-east, near the Tower of Ilgalar.
= The old lion statue. Theocritus of the Tower of Azora watched Morganth through a glyph set at its base.
+ What he learned: Morganth sought the Scythe of Elune, and may have found it.

## redridge-mountains-keeshan
A corporal dragged from the battle at the keep
is held in a cave of the black-rock orcs, north of the lake town,
just west of the pass to the burning lands.
Find where they keep him.
? The Blackrock camp north of Lakeshire, west of the pass to the Burning Steppes.
= Corporal Keeshan's cave. The notice in Lakeshire was right.
+ Most of his regiment was killed. He took a blow to the head, and woke a prisoner here.

## redridge-mountains-lakeshire
In the lake town, by order of the magistrate,
a notice asks after a corporal dragged away from a battle,
and says where he is believed to be held.
? Lakeshire, by the inn.
= Missing: Corporal Keeshan. Marshal Marris pays for his recovery.
+ By mandate of Magistrate Solomon; and the notice is right about where, as whoever goes looking finds.
