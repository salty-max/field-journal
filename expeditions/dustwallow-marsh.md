---
zone: 1445   # Dustwallow Marsh
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: dustwallow-marsh-theramore
    tier: town
    faction: alliance   # its town's: for that faction alone
    gestures: [SALUTE, BOW]
    creature: 4965   # Pained, dump 66.2, 49.1, at Lady Jaina Proudmoore's side
    hint_area: { x: 66.0, y: 48.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn; the client's display tables (a night elf); the WoWWiki archive's Pained page (Jaina's guard, beside Archmage Tervosh)"
quarry:
  id: 4339   # Brimgore
  sources: "https://www.wowhead.com/classic/npc=4339/brimgore (period accounts of Flame Breath); the WoWWiki archive's Brimgore page (a black drake); the pinned dump's path and creature_ai_scripts (8873 Flame Breath)"
---
## dustwallow-marsh-theramore
In the human isle's tower, a night elf stands at the Lady's shoulder,
a glowing sword in her hand, and says nothing about why
an elf should guard an archmage of the humans. Pay her a soldier's respect.
? Theramore Isle, in the tower, at Lady Jaina Proudmoore's side.
= Pained, a night elf, Jaina Proudmoore's bodyguard in the tower of Theramore.
+ She shares the Lady's tower with Archmage Tervosh; between them, Jaina is seldom alone.

## quarry
In the south of the marsh, where the black dragonflight breeds its young,
seek a drake among the whelps.
Find him without bringing the whole brood after you.
= Brimgore, an elite black drake of southern Dustwallow.
+ His flame sweeps the ground before his jaws. Companions standing together can all catch the same breath.
