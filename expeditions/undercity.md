---
zone: 1458   # Undercity
home: horde   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: undercity-kelthuzad-book
    tier: near
    reading: Kel'Thuzad and the Forming of the Scourge
    object: 175754   # dump 56.2, 51.0; Wowhead's page alike
    hint_area: { x: 52.5, y: 49.6, r: 8 }
    danger: "Quiet"
    sources: "object 175754's text"
  - id: undercity-bethor
    tier: off
    creature: 1498   # Bethor Iceshard, dump 84.1, 17.4; Wowhead 84.2, 17.4
    hint_area: { x: 83.9, y: 19.4, r: 4 }
    danger: "Quiet"
    sources: "quests 405, 366"
  - id: undercity-terenas
    tier: hidden
    reading: Here Lies King Terenas Menethil II
    object: 175659   # dump 66.0, 43.9; Wowhead 65.9, 43.4
    hint_area: { x: 68.6, y: 40.9, r: 8 }
    danger: "Quiet"
    sources: "object 175659's text; the Codex's fall-of-lordaeron page"
# quarry: the zone's own, in the hunts' pass
---
## undercity-kelthuzad-book
In the city under the ruins, a history tells how an archmage
answered a voice from the north, founded a cult among the poor,
and named what rose from the plague the Scourge.
? The Magic Quarter's shelves, in the Undercity.
= Kel'Thuzad and the Forming of the Scourge.
+ 'It was surprisingly easy for Kel'Thuzad to achieve his goal: namely, to transfer the citizens' faith in the Holy Light into belief in Ner'zhul's dark shadow.'

## undercity-bethor
In the quarter of the mages, one who studied with a friend in the city of wizards
has learned that his friend is free of the Lich King too,
and wants him back. Find him.
? The Magic Quarter.
= Bethor Iceshard.
+ He, Gunther Arcanus and Thule Ravenclaw studied together within the Kirin Tor; he enchanted Gunther's book so that Gunther would know him free.

## undercity-terenas
Above the city, in what is left of the palace garden, the last true king
of the land lies under a stone that asks for his son's deeds
not to be laid at his feet. Find the stone.
? In the gardens of the Ruins of Lordaeron, above the Undercity.
= 'Here lies King Terenas Menethil II -- Last True King of Lordaeron. Great were his deeds -- long was his reign -- unthinkable was his death.'
+ 'May the Father lie blameless for the deeds of the son. May the bloodied crown stay lost and forgotten.'
