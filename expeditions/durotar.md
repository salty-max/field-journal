---
zone: 1411   # Durotar
home: horde   # a starting zone: its riddles are its faction's alone, as a capital's
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: durotar-near
    tier: near
    area: Darkspear Strand   # placed: Sen'jin Village's overlay: 56.1, 73.0, half-size 3.7 by 5.6
    hint_area: { x: 59.0, y: 76.0, r: 10 }
    danger: "Quiet"
    sources: "the wiki's Darkspear Strand (the landing; Sen'jin a few yards away); quest 826"
    check: "the strand has no position of its own in the data: the hint's circle covers Sen'jin Village's overlay and the shore beside it; confirm the strand lies inside"
  - id: durotar-off
    tier: off
    reading: Rise of the Horde
    object: 175742   # dump 59.6, 58.1; Wowhead 59.6, 58.2
    hint_area: { x: 55.8, y: 56.7, r: 8 }
    danger: "Guarded (Kul Tiran soldiers)"
    sources: "object 175742's text; quest 784; Warcraft III: Reign of Chaos (Durotar named for Durotan)"
  - id: durotar-hidden
    tier: hidden
    object: 61934   # dump 39.0, 58.2; Wowhead 38.9, 58.2
    hint_area: { x: 40.4, y: 54.5, r: 8 }
    danger: "Quiet (the climb is the danger)"
    sources: "quests 1524, 1525, 1526"
# quarry: the zone's own, in the hunts' pass
---
## durotar-near
Where the land meets the southern sea, a tribe came ashore
with what it could carry, from isles a witch doctor had turned against it,
and built its village a few yards inland, in sight of the isles.
Stand on the sand where they landed.
? The beach below Sen'jin Village.
= The Darkspear Strand. The isles they left are still in sight.
+ Zalazane sends his trolls to the mainland to hex the Darkspear and drag more of them under his sway: 'former Darkspear trolls, now lost to us'.

## durotar-off
In the keep the admiral's men took back on the red land's coast,
a history of the orcs lies among their enemies:
the arenas the warlocks built, the blood the chieftains drank,
and the one chieftain who would not. Read it there.
? South of Razor Hill, Kul Tiras still holds a keep on Durotar's shore.
= Rise of the Horde, at Tiragarde Keep. Durotan alone refused Mannoroth's blood; this land bears his name.
+ The keep fell once, when the Horde threw back the Admiral's attack; his reserves, under Lieutenant Benedict, have retaken it since.

## durotar-hidden
Along the river, before it meets the sea,
a hidden trail climbs one of the highest peaks in the land.
At the top a keeper watches a brazier a third your height,
unworn by the weather, its bowl cool to the touch. Find it.
? Above the Southfury, on Durotar's western side, a hidden trail climbs to a shrine of fire.
= The Brazier of the Dormant Flame, at the shrine Telf Joolam keeps.
+ Telf says many adventurers find their way up looking for treasure or something to slay, and are turned away from a seemingly empty shrine. 'Fire is more than chaos and destruction. It is also about life, and creation.'
