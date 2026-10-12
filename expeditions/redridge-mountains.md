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
    object: 121264   # dump 52.0, 44.7; Wowhead 52.0, 44.9
    hint_area: { x: 55.0, y: 42.1, r: 8 }
    danger: "Guarded (Blackrock orcs nearby)"
    sources: "quest 2282"
  - id: redridge-mountains-lake-thresher
    tier: off
    creature: 14357   # the Lake Thresher: dump 48.1, 55.3 (a round in the deep water) and 42.4, 64.4
    found: target   # it keeps swimming
    hint_area: { x: 46.0, y: 59.0, r: 7 }
    danger: "Deadly (an elite thresher, level 25, in deep water)"
    sources: "the dump's spawns, path and loot (the Threshadon Fang, a dagger, half the time); the WoWWiki archive's Lake Everstill page"
  - id: redridge-mountains-captive
    tier: hidden
    gestures: [COMFORT, SOOTHE, ENCOURAGE]
    creature: 3096   # the Captured Servant of Azora, dump 74.5, 79.5, a ball and chain (object 175544) at his feet
    hint_area: { x: 72.0, y: 77.0, r: 6 }
    danger: "Perilous (the Blackrock camp around him, levels 19 to 23)"
    sources: "the dump's spawns and his wares (three cloaks, one of each); the client's display tables (a gnome); the WoWWiki archive's Render's Valley page; https://www.wowhead.com/classic/item=4790/inferno-cloak (fire resistance)"
  - id: redridge-mountains-lakeshire
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Dark Portal and the Fall of Stormwind
    object: 175745   # dump 26.8, 45.8, by the inn
    hint_area: { x: 25.0, y: 47.0, r: 5 }
    danger: "Quiet"
    sources: "object 175745's text"
quarry:
  id: 14273   # Boulderheart
  sources: "the WoWWiki archive's Boulderheart page (the pass east of the falls); the dump's path and kind (Redridge's only giant)"
---
## redridge-mountains-lockbox
Above the lake road, a mill stands abandoned,
and in it a locked box that no one lost:
an old thief keeps it there, to see which of his pupils can reach it.
Find the box he keeps for them.
? Alther's Mill, just up off the road north-east of Lakeshire.
= Lucius's lockbox. Lakeshire has trained thieves 'for years', and this is their examination.
+ 'Did I forget to mention the orcs? I hear they have been nosing around up by the mill.' Lucius, to the pupil who comes back.

## redridge-mountains-lake-thresher
The murlocs keep the shallows of the lake, and the town keeps its shore.
Out in the deep water, south-east of the docks,
something long-necked and heavy swims its rounds.
Find it, and then get out of the water.
? Lake Everstill, out in the deep water between Lakeshire and the eastern shore.
= The Lake Thresher, an elite threshadon, keeping Lake Everstill's deep water to itself.
+ Half the time, one of its fangs comes away whole: a dagger, of a kind.

## redridge-mountains-captive
In the far south-east, the black-rock orcs keep a camp in a valley,
and by its fire sits a gnome with a ball and chain at his feet.
He served a mage's tower once, and he still has wares,
for whoever can reach him: thread, dye, and cloaks fit for a tower.
Be kind to him.
? Render's Valley, Redridge's south-east, in the Blackrock camp.
= The Captured Servant of Azora, a gnome of the tower in Elwynn, chained in the Blackrock camp, and still selling tailoring supplies.
+ He keeps only one of each cloak: Inferno, Spirit and Sylvan. The Inferno offers protection against fire, useful enough in a valley held by the Blackrock.

## redridge-mountains-lakeshire
In the lake-town inn, find a king's fatal certainty: his walls would hold.
His city fell, and his death came from a blade already inside it.
The account waits on a page.
? Lakeshire, by the inn.
= The Dark Portal and the Fall of Stormwind. Llane held his capital, sure the orcs could never take it; Garona killed him as it fell.
+ In the same book, an orc infant, Durotan's son, found by a human officer named Blackmoore and taken as a slave: 'That infant orc would one day rise to become the greatest leader his people would ever know.'

## quarry
East of the falls below Stonewatch,
a pass climbs into the mountains.
A hill giant walks it, up and back, alone.
= Boulderheart, a hill giant in the pass east of Stonewatch Falls.
+ He is the only true giant recorded in Redridge. His route stays in the high pass; search above the falls, not along the lake road.
