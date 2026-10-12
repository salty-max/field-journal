---
zone: 1448   # Felwood
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: felwood-morlos-aran
    tier: off
    gestures: [PONDER, THINK, MOURN, SIGH]
    area: Morlos'Aran   # placed: the client's overlay: 57.6, 87.9, half-size 3.7 by 4.1
    hint_area: { x: 57.0, y: 87.0, r: 4 }
    danger: "Guarded (felpaw wolves, angerclaw bears and ironbeak owls, levels 47 and 48)"
    sources: "the WoWWiki archive's Morlos'Aran page (its sister ruins); the dump's spawns"
quarry:
  id: 7137   # Immolatus
  sources: "https://wowwiki-archive.fandom.com/wiki/Immolatus (Knock Away, original level 56 rare elite); the pinned dump's path and creature_ai_scripts (10101 Knock Away); the dump's loot (Lifeless Stone, Deeprock Salt, Core of Earth)"
---
## felwood-morlos-aran
At the southern edge of the poisoned wood, the stones of an elven town still stand,
and its name ends as theirs did on the dark shore and in the forest to the south.
Remember the towns whose names it echoes, and what has become of this one.
? Morlos'Aran, at Felwood's southern edge.
= Morlos'Aran, one of the old night elf settlements whose names end alike: Ameth'Aran and Bashal'Aran in Darkshore, Ordil'Aran in Ashenvale, Tethris Aran in Desolace.
+ A druid of the Emerald Circle keeps watch by the ruins; the wood around him is still sick.

## quarry
In the scarred vale where fire once fell on the forest,
an infernal still burns.
Seek the named demon among the forest's wounds.
= Immolatus, an elite infernal of Shatter Scar Vale.
+ When the fire goes out of him, stone is what remains: lifeless stone mostly, sometimes salt from deep rock or a core of earth.
