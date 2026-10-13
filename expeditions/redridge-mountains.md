---
zone: 1433   # Redridge Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: redridge-mountains-docks
    tier: near
    faction: alliance   # Lakeshire's docks: the town's guards keep the Horde away
    gestures: [SIT]
    name: Roger and Jamin
    creature: 5607   # Roger, dump 28.3, 53.5, at the end of Lakeshire's docks; Jamin (5608) beside him
    hint_area: { x: 29.0, y: 52.0, r: 4 }
    danger: "Quiet"
    sources: "the dump: Roger's and Jamin's words (broadcast texts 1922 to 1924; creature_ai_scripts 560701, every two and a half to three minutes; dbscripts_on_relay 15); warcraft.wiki.gg's Jamin page (two boys fishing at Lakeshire)"
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
## redridge-mountains-docks
At the end of the lake town's docks, two boys keep the same afternoon every day.
One asks the other what he wants to do.
The other doesn't know, and asks him back.
Join them on the planks while they make up their minds.
? Lakeshire's docks, on Lake Everstill.
= Roger and Jamin, two boys of Lakeshire: 'So what do you want to do today?' 'I dunno. What do you want to do?' 'Fishing sounds good.'
+ The question comes round every two and a half to three minutes, and the answer has never once changed.

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
= The Dark Portal and the Fall of Stormwind. Llane held his capital, sure the orcs could never take it. Garona killed him as it fell.
+ In the same book, an orc infant, Durotan's son, found by a human officer named Blackmoore and taken as a slave: 'That infant orc would one day rise to become the greatest leader his people would ever know.'

## quarry
East of the falls below Stonewatch,
a pass climbs into the mountains.
A hill giant walks it, up and back, alone.
= Boulderheart, a hill giant in the pass east of Stonewatch Falls.
+ He is Redridge's only giant, and never comes down from the pass to the lake road.
