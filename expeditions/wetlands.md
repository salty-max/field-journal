---
zone: 1437   # Wetlands
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: wetlands-near
    tier: near
    gesture: KNEEL
    object: 2652   # dump 51.3, 8.0; Wowhead 51.2, 8.0
    hint_area: { x: 50.6, y: 4.1, r: 8 }
    danger: "Guarded (Dark Iron dwarves)"
    sources: "quests 631, 632"
  - id: wetlands-off
    tier: off
    area: Ironbeard's Tomb   # placed: the client's overlay: 44.7, 31.1, half-size 6.2 by 8.6
    hint_area: { x: 46.0, y: 29.0, r: 10 }
    danger: "Guarded (oozes)"
    sources: "quest 470"
  - id: wetlands-hidden
    tier: hidden
    object: 112948   # dump 14.4, 24.0; Wowhead 14.3, 24.0
    hint_area: { x: 11.2, y: 21.5, r: 8 }
    danger: "Perilous (drowned sailors; the deep)"
    sources: "quests 290, 292"
# quarry: the zone's own, in the hunts' pass
---
## wetlands-near
On the great bridge to the north, a small dwarf lies where he was ambushed,
sent to scout the eastern span after the explosion.
His name is on his helmet; a parchment lies by his fist.
Kneel by him.
? Where the Thandol Span crosses toward Arathi, the dwarves lost a scout.
= Ebenezer Rustlocke, 'Ol' Rustlocke'. The parchment by his fist was grave news.
+ Longbraid sent him days before; with Dun Modr under siege, no one could go looking.

## wetlands-off
North of the marsh, near the dwarves' besieged fort,
an old tomb has filled with oozes.
A woman of the harbour came here every week, until one swallowed her bag.
Find the tomb she visits.
? North-east of Menethil Harbor, near Dun Modr, west of the road.
= Ironbeard's Tomb. Sida of Menethil Harbor visits it every week, and never says for whom.
+ She threw her bag at an ooze to get away; it sucked the bag right up, and she cannot tell which ooze it was.

## wetlands-hidden
Off the western coast a ship of the Third Fleet lies on the sea floor,
its captain still walking its deck.
In its strongbox, a cursed eye the crew should never have carried.
Find the strongbox.
? The wrecks off the coast, north of Menethil Harbor.
= The Intrepid's strongbox, and the Cursed Eye of Paleth it held.
+ Glorin Steelbrow never knew the Third Fleet carried such an Eye: 'It's no wonder Fitzsimmons was so spooked.'
