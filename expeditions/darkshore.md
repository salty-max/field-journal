---
zone: 1439   # Darkshore
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: darkshore-near
    tier: near
    area: The Master's Glaive   # placed: the client's overlay: 41.4, 88.7, half-size 4.5 by 5.6
    hint_area: { x: 43.0, y: 86.0, r: 9 }
    danger: "Guarded (the Twilight's Hammer)"
    sources: "the Codex's masters-glaive page"
  - id: darkshore-off
    tier: off
    object: 17189   # dump 42.7, 63.1; Wowhead 42.7, 63.1
    hint_area: { x: 39.2, y: 61.1, r: 8 }
    danger: "Guarded (the Highborne's spirits)"
    sources: "quest 953"
  - id: darkshore-hidden
    tier: hidden
    object: 175226   # dump 36.0, 70.9; Wowhead 36.1, 70.9
    hint_area: { x: 34.4, y: 74.6, r: 8 }
    danger: "Guarded (murlocs)"
    sources: "quest 4728"
# quarry: the zone's own, in the hunts' pass
---
## darkshore-near
In the south of the dark shore a blade stands driven in the earth,
too great for any hand that walks the world now.
The Ancient of Lore says it marks where an old lord of the earth fell,
and the cult that worships such lords has come to it. Stand beneath it.
? South of the road to Ashenvale, the glaive is hard to miss and easy not to look at.
= The Master's Glaive. Onu keeps its story; the Twilight's Hammer has come for its secret.
+ The cultists gather at the Glaive and in the caves around it with books of names that should not be spoken.

## darkshore-off
In ruins where the queen's servants once worked their magic freely,
two great tablets tell the place's story and its fall.
The spirits of those who lived there do not like them read.
Find the tablet of the fall.
? The ruins of Ameth'Aran, south of Auberdine.
= The Fall of Ameth'Aran. Sentinel Tysha Moonblade began reading the tablets and fled the spirits.
+ The kaldorei keep few records of the time of the War of the Ancients, near the Well's destruction; these tablets are some of them.

## darkshore-hidden
On the southern strand a giant of the sea lies gutted on the sand.
Someone came to study it and left their tools behind:
a wheelbarrow, picks, and the murlocs at the meat.
Find the creature on the beach.
? Darkshore's long western beaches, south of Auberdine, keep more than one dead giant.
= One of Darkshore's beached sea creatures. The tools were the Explorers' League's, until the murlocs chased them off.
+ Gwennyth Bly'Leggonde of the Temple of the Moon studies the beached giants from Auberdine, and pays for their bones.
