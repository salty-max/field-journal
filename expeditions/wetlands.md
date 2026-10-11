---
zone: 1437   # Wetlands
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: wetlands-rustlocke
    tier: near
    gestures: [SALUTE, MOURN, KNEEL]
    object: 2652   # dump 51.3, 8.0; Wowhead 51.2, 8.0
    hint_area: { x: 47.7, y: 6.2, r: 8 }
    danger: "Guarded (Dark Iron dwarves)"
    sources: "quests 631, 632"
  - id: wetlands-ironbeard
    tier: off
    area: Ironbeard's Tomb   # placed: the client's overlay: 44.7, 31.1, half-size 6.2 by 8.6
    hint_area: { x: 46.0, y: 29.0, r: 10 }
    danger: "Guarded (oozes)"
    sources: "quest 470"
  - id: wetlands-whelgar
    tier: off
    area: Whelgar's Excavation Site   # placed: the client's overlay: 35.9, 49.0, half-size 5.0 by 4.9
    hint_area: { x: 37.0, y: 50.5, r: 8 }
    danger: "Guarded (Mottled raptors)"
    sources: "quests 294, 296, 299"
  - id: wetlands-intrepid
    tier: hidden
    object: 112948   # dump 14.4, 24.0; Wowhead 14.3, 24.0
    hint_area: { x: 17.6, y: 21.6, r: 8 }
    danger: "Perilous (drowned sailors; the deep)"
    sources: "quests 290, 292"
  - id: wetlands-menethil
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Battle of Grim Batol
    object: 175750   # dump 10.8, 60.8; Wowhead's page alike
    hint_area: { x: 9.0, y: 64.4, r: 8 }
    danger: "Quiet"
    sources: "object 175750's text"
# quarry: the zone's own, in the hunts' pass
---
## wetlands-rustlocke
On the great bridge to the north, a small dwarf lies where he was ambushed,
sent to scout the eastern span after the explosion.
His name is on his helmet; a parchment lies by his fist.
He died at his post.
? Where the Thandol Span crosses toward Arathi, the dwarves lost a scout.
= Ebenezer Rustlocke, 'Ol' Rustlocke'. The parchment by his fist was grave news.
+ Longbraid sent him days before; with Dun Modr under siege, no one could go looking.

## wetlands-ironbeard
North of the marsh, near the dwarves' besieged fort,
an old tomb has filled with oozes.
A woman of the harbour came here every week, until one swallowed her bag.
Find the tomb she visits.
? North-east of Menethil Harbor, near Dun Modr, west of the road.
= Ironbeard's Tomb. Sida of Menethil Harbor visits it every week, and never says for whom.
+ She threw her bag at an ooze to get away; it sucked the bag right up, and she cannot tell which ooze it was.

## wetlands-whelgar
East of the harbour, dwarves dug up old bones and a tablet in the Titans' script,
and the bones brought the raptors.
Three of them are still trapped on the bluff above the dig,
the oldest with a tablet that speaks of old gods beneath the land.
? Whelgar's Excavation Site, east of Menethil Harbor.
= Whelgar's Excavation Site. Prospector Whelgar, Merrin and Ormer hold the bluff; the raptors took the rest.
+ The Goaz Stone, made whole, begins: 'Old Gods... Chained Beneath the Land.' 'This is the beginning of something epic,' says Whelgar.

## wetlands-intrepid
Off the western coast a ship of the Third Fleet lies on the sea floor,
its captain still walking its deck.
In its strongbox, a cursed eye the crew should never have carried.
Find the strongbox.
? The wrecks off the coast, north of Menethil Harbor.
= The Intrepid's strongbox, and the Cursed Eye of Paleth it held.
+ Glorin Steelbrow never knew the Third Fleet carried such an Eye: 'It's no wonder Fitzsimmons was so spooked.'

## wetlands-menethil
In the harbour town, a history tells of the mountain
at the far end of the marsh: the orcs who held the Dragonqueen there,
and how her dragons tore the fortress apart when she was free.
? Menethil Harbor.
= The Battle of Grim Batol, in Menethil Harbor. The mountain it tells of stands at the Wetlands' eastern edge.
+ Grim Batol was a Wildhammer stronghold first, 'some say cursed'; a small band led by the mage Rhonin destroyed the Demon Soul and freed Alexstrasza.
