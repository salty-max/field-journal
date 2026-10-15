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
  sources: "the WoWWiki archive's Ursol'lok page (his roam about Satyrnaar); https://www.wowhead.com/classic/npc=12037/ursollok (period taming accounts); the pinned dump's spawn and kind (a bear); the WoWWiki archive's Ursol page (the bear twins, gods to the furbolgs) and the War of the Ancients trilogy (Ursoc and Ursol against the Legion)"
---
## ashenvale-grom
In a canyon where demons still walk,
a warchief carved words for his big brother,
whose name meant giant's heart,
who stood alone before the demon and bought his people's freedom with his blood.
Leave him what a warrior is owed.
? Demon Fall Canyon, in Ashenvale's south-east. A soldier's salute belongs at this monument.
= 'Lok'Tar ogar, big brother. May the Warsong never fade.' Thrall wrote it.
+ Grom was the first chieftain to drink Mannoroth's blood, and the one who killed the demon: 'the curse of our people began and ended with Grom.'

## ashenvale-astranaar
One of the world's five keepers was given a duty she could fulfil only in sleep.
In the sentinels' town beside the lake, find the page that names her charge.
Her four kin received theirs on the same page.
? Astranaar. Read the book that recounts the five dragonflights' duties.
= Charge of the Dragonflights, in Astranaar: the Titans entrusted the world to five dragons, and gave Ysera the Emerald Dream to watch over.
+ Ysera fell into an eternal trance, bound to the waking Dream of Creation. Her green dragons keep its doors, the great tree of Duskwood's Twilight Grove among them.

## quarry
A great bear keeps to the east of the forest,
roaming around the satyrs' ruins.
The name on him belongs to no satyr.
= Ursol'lok, a bear of eastern Ashenvale, roaming around Satyrnaar.
+ The name is older than the satyrs': Ursol and his twin Ursoc, bear gods to the furbolgs, fought beside the night elves in the War of the Ancients.
