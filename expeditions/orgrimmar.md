---
zone: 1454   # Orgrimmar
home: horde   # a capital: its riddles are its faction's alone
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: orgrimmar-thrall
    tier: near
    gestures: [SALUTE, BOW]
    where: { x: 31.7, y: 37.8, r: 1 }   # Thrall, dump 31.7, 37.8; Wowhead 32.0, 37.8
    hint_area: { x: 33.3, y: 36.5, r: 4 }
    danger: "Quiet"
    sources: "the Codex's thrall and orgrimmar pages"
  - id: orgrimmar-mannoroth-armor
    tier: off
    reading: The Armor of Mannoroth
    object: 175658   # dump 45.2, 34.7; Wowhead's page alike
    hint_area: { x: 43.6, y: 31.0, r: 8 }
    danger: "Quiet"
    sources: "object 175658's text; object 21004's text"
  - id: orgrimmar-neeru
    tier: hidden
    where: { x: 49.5, y: 50.6, r: 1 }   # Neeru Fireblade, dump 49.5, 50.6; Wowhead 49.4, 50.4
    hint_area: { x: 48.8, y: 48.7, r: 4 }
    danger: "Quiet"
    sources: "quest 829"
# quarry: the zone's own, in the hunts' pass
---
## orgrimmar-thrall
In the hold named for the chieftain who drank the demon's blood and then killed the demon,
the warchief who was raised a slave and kept the name
carries the old warchief's hammer. Show him the respect the Horde shows its warchief.
? Grommash Hold, in the Valley of Wisdom.
= Thrall, Warchief of the Horde, son of Durotan.
+ He escaped Durnholde with the help of a human girl, found his father's clan in Alterac, and with Grom and Doomhammer broke open the camps.

## orgrimmar-mannoroth-armor
In the city named for a fallen warchief, the plates of a demon hang on display,
worn by the creature that first cursed the orcs with bloodlust,
defeated by the act of one brave orc. Find them.
? In the Valley of Strength, in the middle of Orgrimmar.
= The Armor of Mannoroth.
+ 'Let these plates always remind us of how far we've come and how hard we fought to regain our honor.' - Thrall. Grom's monument stands in Ashenvale, where he died.

## orgrimmar-neeru
In the shadowed cleft beneath the city, a warlock claims
he studies the occult only to thwart demons.
The shamans are not sure whether to believe him. Find him.
? The Cleft of Shadow, in Orgrimmar.
= Neeru Fireblade, of the Cleft of Shadow.
+ Margoz of Razor Hill sends him the Burning Blade's searing collars: 'Be that true or false, we may need his aid against the demonic cult in Durotar.'
