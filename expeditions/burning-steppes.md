---
zone: 1428   # Burning Steppes
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: burning-steppes-pillar-of-ash
    tier: near
    gestures: [SALUTE, KNEEL, BOW, MOURN]
    area: The Pillar of Ash   # placed: the client's overlay: 50.1, 56.5, half-size 8.7 by 7.9
    hint_area: { x: 50.0, y: 56.0, r: 8 }
    danger: "Perilous (Blackrock soldiers, sorcerers and slayers, levels 54 to 56)"
    sources: "object 21581's text (Aftermath of the Second War: Lothar's fall in the center of the Steppes); the WoWWiki archive's The Pillar of Ash page (the statue)"
  - id: burning-steppes-altar-of-storms
    tier: off
    area: Altar of Storms   # placed: the client's overlay: 15.7, 32.2, half-size 5.7 by 9.7
    hint_area: { x: 17.0, y: 30.0, r: 10 }
    danger: "Perilous (Blackrock warlocks)"
    sources: "the Codex's altar-of-storms page"
  - id: burning-steppes-flame-crest
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [PET, PAT, SOOTHE, COMFORT, LISTEN]
    creature: 10262   # Opus, Kibler's parrot, dump 65.8, 21.7
    found: target   # in the town: only by finding him
    hint_area: { x: 66.0, y: 23.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and his words (broadcast texts 5539, 5543-5545); the WoWWiki archive's Opus page"
quarry:
  id: 10119   # Volchan
  sources: "the WoWWiki archive's Volchan page (a molten giant, his round); the pinned dump's path, loot (the Plans: Volcanic Hammer) and creature_ai_scripts (13376 Fire Shield, 12470 Fire Nova); the dump's Molten Giants (11658), all in the Molten Core"
---
## burning-steppes-pillar-of-ash
In the very middle of the burning plain, the orcs have raised their towers,
and among them stands the statue of a man, which they have not torn down.
The histories say a hero of the Alliance fell in the center of these Steppes,
in single combat with the Horde's warchief. Pay your respects.
? The Pillar of Ash, in the middle of the Burning Steppes. Bow before the fallen man's statue.
= The Pillar of Ash: among the Blackrock towers, the statue of a human hero, in the center of the Steppes, where Doomhammer fought Lothar and Lothar fell.
+ Doomhammer won the duel, says Aftermath of the Second War, but the death did not break the Alliance as he had hoped: Turalyon rallied it, and the Horde was beaten.

## burning-steppes-altar-of-storms
In the shadow of the black mountain, an altar of the old Horde's warlocks still stands,
where magic once made ogres cunning and taught them spells.
Warlocks still gather there. Find the altar.
? The Altar of Storms, in the west of the Burning Steppes, under Blackrock Spire.
= The Altar of Storms. Mor'zul Bloodbringer camps beside it.
+ In the Second War, rites worked at such altars turned ogres into ogre magi.

## burning-steppes-flame-crest
In the Horde's camp on the burning plain, a goblin keeps exotic pets,
and one of them keeps everybody's secrets: it repeats whatever it has heard,
coughing all the while. Be kind to it, and hear it out.
? Flame Crest, by Kibler. The coughing pet has plenty to say. Listen to it.
= Opus, Kibler's parrot, at Flame Crest: 'SQUAWK!! *cough* *cough* I need to quit smoking!'
+ He knows more than he should: 'Kibler is being investigated by G.E.T.A.' And: 'They all go to the Spire but none ever come back... just like Bijou.'

## quarry
Something walks the east of the burning plain, round the ogres' rock,
past the ruined city and down toward the dwarves' vigil, and back:
a giant of molten stone, carrying a smith's plans for a hammer of the same fire.
= Volchan, an elite molten giant, walking the east of the Burning Steppes: the only one who carries the Plans: Volcanic Hammer.
+ The other molten giants stand deep under Blackrock Mountain, in the Molten Core among Ragnaros's servants. Volchan walks under the open sky.
