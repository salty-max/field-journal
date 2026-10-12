---
zone: 1422   # Western Plaguelands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: western-plaguelands-chillwind
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 11609   # Alexia Ironknife, dump 42.9, 84.0
    found: target   # in the camp: only by speaking to her
    hint_area: { x: 43.5, y: 83.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and her words"
quarry:
  id: 1851   # The Husk
  sources: "the WoWWiki archive's The Husk and The Weeping Cave pages; the pinned dump's spawn and creature_ai_scripts (17230 Infected Wound); the dump's loot (Living Essence, 96%; Firebloom, Icecap, Sungrass)"
---
## western-plaguelands-chillwind
In the Alliance's camp at the plague's southern edge, a traveller rests before Hearthglen,
and passes on what she has heard: the Crusade once had a mage making bows and guns,
and killed him before his work ever left the town. Ask her about it.
? Chillwind Camp.
= Alexia Ironknife, resting at Chillwind before Hearthglen: the Crusade's own weapon-maker, she has heard, was killed by the Crusade.
+ At the Bulwark, the Horde's camp, a traveller tells the same tale, and adds that the wizard finished a remarkable weapon first.

## quarry
In a cave above the river at the plague's eastern edge,
bog beasts and oozes keep the dark.
Among them, seek a bog beast with a dead thing's name.
= The Husk, a bog beast of level 62, at the Weeping Cave.
+ Herbs take root on him: Firebloom, Icecap and Sungrass come away when he falls, and a living essence nearly always.
