---
zone: 1439   # Darkshore
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: darkshore-masters-glaive
    tier: near
    gestures: [AWE, GAZE]
    area: The Master's Glaive   # placed: the client's overlay: 41.4, 88.7, half-size 4.5 by 5.6
    hint_area: { x: 43.0, y: 86.0, r: 9 }
    danger: "Guarded (the Twilight's Hammer)"
    sources: "the Codex's masters-glaive page"
  - id: darkshore-ameth-aran
    tier: off
    object: 17189   # dump 42.7, 63.1; Wowhead 42.7, 63.1
    hint_area: { x: 43.3, y: 67.1, r: 8 }
    danger: "Guarded (the Highborne's spirits)"
    sources: "quest 953"
  - id: darkshore-beached-creature
    tier: hidden
    object: 175226   # dump 36.0, 70.9; Wowhead 36.1, 70.9
    hint_area: { x: 36.8, y: 67.0, r: 8 }
    danger: "Guarded (murlocs)"
    sources: "quest 4728"
  - id: darkshore-auberdine
    tier: town
    faction: alliance   # its town's: for that faction alone
    where: { x: 35.7, y: 43.7, r: 1 }   # Cerellean Whiteclaw, dump 35.7, 43.7; Wowhead 35.8, 43.6
    hint_area: { x: 35.7, y: 46.2, r: 5 }
    danger: "Quiet"
    sources: "quest 963"
# quarry: the zone's own, in the hunts' pass
---
## darkshore-masters-glaive
In the south of the dark shore a blade stands driven in the earth,
too great for any hand that walks the world now.
The Ancient of Lore says it marks where an old lord of the earth fell,
and the cult that worships such lords has come to it.
Stand beneath it, and feel how small you are.
? South of the road to Ashenvale, the glaive is hard to miss and easy not to look at.
= The Master's Glaive. Onu keeps its story; the Twilight's Hammer has come for its secret.
+ The cultists gather at the Glaive and in the caves around it with books of names that should not be spoken.

## darkshore-ameth-aran
In ruins where the queen's servants once worked their magic freely,
two great tablets tell the place's story and its fall.
The spirits of those who lived there do not like them read.
Find the tablet of the fall.
? The ruins of Ameth'Aran, south of Auberdine.
= The Fall of Ameth'Aran. Sentinel Tysha Moonblade began reading the tablets and fled the spirits.
+ The kaldorei keep few records of the time of the War of the Ancients, near the Well's destruction; these tablets are some of them.

## darkshore-beached-creature
On the southern strand a giant of the sea lies gutted on the sand.
Someone came to study it and left their tools behind:
a wheelbarrow, picks, and the murlocs at the meat.
Find the creature on the beach.
? Darkshore's long western beaches, south of Auberdine, keep more than one dead giant.
= One of Darkshore's beached sea creatures. The tools were the Explorers' League's, until the murlocs chased them off.
+ Gwennyth Bly'Leggonde of the Temple of the Moon studies the beached giants from Auberdine, and pays for their bones.

## darkshore-auberdine
At the edge of the harbour town, a kaldorei sits apart.
Ten thousand years ago the city of his love was destroyed,
and he has found her spirit in its ruins.
He cannot bring himself to free her. Find him.
? Auberdine, at the town's edge.
= Cerellean Whiteclaw. Anaya Dawnrunner died at Ameth'Aran.
+ 'Perhaps it would have been better... if I had done it myself. But even after these thousands of years, I could not bear to raise my hand against my beloved.'
