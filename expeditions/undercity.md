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
  - id: undercity-theresa
    tier: off
    gestures: [PITY, SHUDDER, SIGH]
    creature: 5697   # Theresa, Gerard's Mindslave, dump 52.7, 34.7; Gerard Abernathy (5696) beside her
    hint_area: { x: 52.0, y: 35.5, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns and the scene's words (broadcast texts 1994-2014); the WoWWiki archive's Theresa and Gerard Abernathy pages"
  - id: undercity-terenas
    tier: hidden
    reading: Here Lies King Terenas Menethil II
    object: 175659   # dump 66.0, 43.9; Wowhead 65.9, 43.4
    hint_area: { x: 68.6, y: 40.9, r: 8 }
    danger: "Quiet"
    sources: "object 175659's text; the Codex's fall-of-lordaeron page"
# no quarry: a capital has riddles alone
---
## undercity-kelthuzad-book
In the city beneath the ruins, seek a preacher whose master spoke from the frozen north.
He promised the poor equality and a life that would never end.
His congregation's story stands among the herbalists' books.
? In the Undercity, by the herbalists: the Alliestars' shop.
= Kel'Thuzad and the Forming of the Scourge. The former archmage founded the Cult of the Damned to serve Ner'zhul, and named the undead rising from the plague the Scourge.
+ 'It was surprisingly easy for Kel'Thuzad to achieve his goal: namely, to transfer the citizens' faith in the Holy Light into belief in Ner'zhul's dark shadow.'

## undercity-theresa
In the quarter of the city's soldiers, three of the Forsaken stand around a living woman,
and one of them is very proud of her. He sends her across the bridge on errands,
and she always comes back. Let your face say what you think of it.
? The War Quarter, in the Undercity.
= Theresa, Gerard Abernathy's mindslave: 'Theresa, take this to Father Lankester.' 'Yes My Lord.'
+ 'I managed to discover that certain parts of the brain when removed or stimulated will make a subject much more docile.' Even his companions ask him how he did it.

## undercity-terenas
Above the city, in what is left of the palace garden, the last true king
of the land lies under a stone that asks for his son's deeds
not to be laid at his feet. Find the stone.
? In the gardens of the Ruins of Lordaeron, above the Undercity.
= 'Here lies King Terenas Menethil II -- Last True King of Lordaeron. Great were his deeds -- long was his reign -- unthinkable was his death.'
+ 'May the Father lie blameless for the deeds of the son. May the bloodied crown stay lost and forgotten.'
