---
zone: 1440   # Ashenvale
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: ashenvale-grom
    tier: off
    gestures: [SALUTE, BOW, KNEEL]
    object: 21004   # dump 82.8, 79.1; Wowhead 82.9, 79.1
    hint_area: { x: 81.8, y: 83.0, r: 8 }
    danger: "Perilous (the Legion's servants)"
    sources: "object 21004's text; object 175742's text; the Codex's demon-fall-canyon page"
  - id: ashenvale-astranaar
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Charge of the Dragonflights
    object: 175726   # dump 34.8, 49.7; Wowhead 34.8, 49.8
    hint_area: { x: 31.9, y: 52.5, r: 8 }
    danger: "Quiet"
    sources: "object 175726's text; the Codex's dragons-of-nightmare page"
quarry:
  id: 12037   # Ursol'lok
  sources: "the WoWWiki archive's Ursol'lok page (his roam about Satyrnaar, 10.5 to 16 hours); the dump's spawn and kind (a bear)"
---
## ashenvale-grom
In a canyon where demons still walk,
a warchief carved words for his big brother,
whose name meant giant's heart,
who stood alone before the demon and bought his people's freedom with his blood.
Leave him what a warrior is owed.
? Demon Fall Canyon, in Ashenvale's south-east.
= 'Lok'Tar ogar, big brother. May the Warsong never fade.' Thrall wrote it.
+ Grom was the first chieftain to drink Mannoroth's blood, and the one who killed the demon: 'the curse of our people began and ended with Grom.'

## ashenvale-astranaar
In the sentinels' town by the lake, a history tells
how the Titans chose five dragons to keep the world,
and gave one of them the Dream to watch over in her sleep.
? Astranaar.
= Charge of the Dragonflights, in Astranaar.
+ Ysera fell into an eternal trance, bound to the waking Dream of Creation; her green dragons keep its doors, the great tree of Duskwood's Twilight Grove among them.

## quarry
A great bear keeps to the east of the forest, around the satyrs' ruins,
and goes where he likes among them.
Kill him, and you will wait half a day for the next.
= Ursol'lok, a bear of eastern Ashenvale, roaming around Satyrnaar.
+ Ten hours and a half at the least between one Ursol'lok and the next; sixteen at the most.
