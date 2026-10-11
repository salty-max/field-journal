---
zone: 1444   # Feralas
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: feralas-dire-maul
    tier: near
    area: Dire Maul   # placed: the client's overlay: 58.9, 41.9, half-size 6.5 by 6.7
    hint_area: { x: 57.0, y: 43.0, r: 8 }
    danger: "Perilous (ogres)"
    sources: "the Codex's dire-maul and shendralar pages"
  - id: feralas-colossals
    tier: off
    creature: 7773   # Marli Wishrunner, dump 45.8, 16.5; Wowhead 45.8, 16.4
    hint_area: { x: 45.6, y: 19.0, r: 5 }
    danger: "Quiet"
    sources: "quest 3567"
  - id: feralas-courier-boat
    tier: off
    object: 164909   # dump 45.4, 65.0; Wowhead 45.4, 64.9
    hint_area: { x: 41.9, y: 63.0, r: 8 }
    danger: "Guarded"
    sources: "quest 4125"
  - id: feralas-equinex
    tier: hidden
    object: 144063   # dump 38.8, 13.2; Wowhead 38.9, 13.2
    hint_area: { x: 42.7, y: 14.1, r: 8 }
    danger: "Perilous"
    sources: "quests 2879, 2942"
  - id: feralas-feathermoon
    tier: town
    faction: alliance   # its town's: for that faction alone
    gestures: [SALUTE, BOW]
    creature: 3936   # Shandris Feathermoon, dump 30.3, 46.2; Wowhead 30.2, 46.0
    hint_area: { x: 28.5, y: 44.5, r: 5 }
    danger: "Quiet"
    sources: "the Codex's shandris-feathermoon and feathermoon-stronghold pages"
  - id: feralas-thalanaar
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 4048   # Falfindel Waywarder, dump 89.6, 46.6; Wowhead 89.6, 46.6
    hint_area: { x: 90.2, y: 49.0, r: 5 }
    danger: "Quiet"
    sources: "quests 1100, 1101"
  - id: feralas-mojache
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 4544   # Krueg Skullsplitter, dump 75.9, 42.7; Wowhead's page alike
    hint_area: { x: 74.5, y: 40.7, r: 5 }
    danger: "Quiet"
    sources: "quest 2973"
quarry:
  id: 14661
  sources: "quest 7731 (Hadoken Swiftstrider)"
---
## feralas-dire-maul
Among the giant trees stands a city of white stone
the old queen built to keep her most prized secrets.
It survived the breaking of the world, and is broken now in other ways.
Find its gates.
? Dire Maul, in the middle of Feralas, on the road from Camp Mojache.
= Dire Maul, that was Eldre'Thalas.
+ The Shen'dralar who stayed bound the demon Immol'thar beneath the city with five pylons, and have drained his power to sustain themselves for thousands of years.

## feralas-colossals
Below two colossal rocks in the north of the forest,
someone offers travellers the view from the top,
and warns them to think about how they will come down.
Find the one who sends them up.
? The Twin Colossals, in the north of Feralas.
= Marli Wishrunner, at the foot of the Twin Colossals.
+ 'I can send you there. Do consider how you will get down, though. This is a one way trip only.'

## feralas-courier-boat
A courier of the moon-elves' island took a rowboat down the coast
to slip past the Horde's camp, and never reached the other side.
His boat is somewhere along the shore. Find it.
? The Forgotten Coast, south of Feathermoon Stronghold.
= Raschal's rowboat: holes riddle its port side, the Feathermoon crest is painted on the starboard.
+ Whatever broke the boat most likely tried to snap it in two.

## feralas-equinex
In ruins west of the dreaming tree, four old flames still burn,
and a monolith of cold stone waits for a key made of their light.
Inside it, something was hidden on purpose. Find the monolith.
? The Ruins of Ravenwind, in Feralas's north-west.
= The Equinex Monolith.
+ Inside lay the Morrow Stone; Troyas Moonbreeze, in Feathermoon, is still studying what it is for.

## feralas-feathermoon
On an island off the coast stands a fortress named for its general,
a child who fled a burning city in the War of the Ancients,
taken in by the high priestess, and a Sentinel ever since.
Show her the respect a general is owed.
? Feathermoon Stronghold, on Sardor Isle.
= General Shandris Feathermoon.
+ Her service beside Tyrande began in the War of the Ancients, when she was a child fleeing Ara-Hinam, believed orphaned.

## feralas-thalanaar
At the moon-elves' outpost on the edge of the plains,
a ranger reads a dead dwarf's journal
and calls him a brave soul. Find him.
? Thalanaar, on the road between Feralas and Thousand Needles.
= Falfindel Waywarder of Thalanaar.
+ He wants the crone of the Kraul dead, and to learn what corrupted the resting place of Agamaggan: 'I fear the answer to that question lies in treachery as well...'

## feralas-mojache
In the tauren camp among the giant trees, one of the Horde far from Orgrimmar
is making a new cloak for his life-mate, who loves new clothes,
and wants it to shine with the wings of faerie dragons. Find him.
? Camp Mojache.
= Krueg Skullsplitter, of Camp Mojache.
+ His life-mate is Korrin; they came to Feralas on a mission for their masters in Orgrimmar.

## quarry
In the twisted ground of the eastern deep, insects have come,
and one of them is larger than the rest,
wandering the warped terrain with an aura the others lack.
Camp Mojache gave it a name, and wants its glands.
= Stinglasher, named by the scouts of Camp Mojache. Hadoken Swiftstrider wants its secretion glands, to learn how to meet the new threat.
+ If it is one of their strongest, Hadoken says, its study will be worth a great deal in time.
