---
zone: 1454   # Orgrimmar
home: horde   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: orgrimmar-mannoroth-armor
    tier: near
    reading: The Armor of Mannoroth
    object: 175658   # dump 45.2, 34.7; Wowhead's page alike
    hint_area: { x: 43.6, y: 31.0, r: 8 }
    danger: "Quiet"
    sources: "object 175658's text; object 21004's text"
  - id: orgrimmar-orphanage
    tier: hidden
    gestures: [WAVE, HELLO, GREET, SMILE, PAT, COMFORT]
    creature: 14498   # Tosamina, dump 70.6, 23.7, among the Horde Orphans (14499) in the Drag
    companions: [14499]   # kindness addressed to a child counts too
    hint_area: { x: 70.5, y: 24.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns (the orphans, Matron Battlewail, Tosamina); the WoWWiki archive's Tosamina page"
# no quarry: a capital has riddles alone
---
## orgrimmar-mannoroth-armor
In the city named for a fallen warchief, the plates of a demon hang on display,
worn by the creature that first cursed the orcs with bloodlust,
defeated by the act of one brave orc. Find them.
? In the Valley of Strength, in the middle of Orgrimmar. Read the inscription beside the displayed armour.
= The Armor of Mannoroth.
+ 'Let these plates always remind us of how far we've come and how hard we fought to regain our honor.' - Thrall. Grom's monument stands in Ashenvale, where he died.

## orgrimmar-orphanage
In the Drag, among the shops and the shouting, the city keeps an orphanage,
and its children run about under the eye of a stern orc who keeps them in line.
Be kind to the little ones.
? The Drag, in Orgrimmar's east. Wave to one of the children, not to their stern keeper.
= The Orgrimmar Orphanage: the city's orphans, Matron Battlewail, and Tosamina, who is heavy-handed with the children.
+ Once a year, in Children's Week, the matron looks for travellers to take an orphan out to see the world.
