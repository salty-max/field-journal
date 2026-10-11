---
zone: 1434   # Stranglethorn Vale
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: stranglethorn-vale-green-hills
    tier: near
    creature: 716   # Barnil Stonepot, dump 35.7, 10.5; Wowhead 35.6, 10.4
    hint_area: { x: 37.0, y: 8.4, r: 5 }
    danger: "Quiet"
    sources: "quest 338; the Codex's nesingwarys-expedition page"
  - id: stranglethorn-vale-arena
    tier: near
    gestures: [CHEER, APPLAUD]
    area: Gurubashi Arena   # placed: the client's overlay: 29.4, 44.2
    hint_area: { x: 30.0, y: 46.0, r: 7 }
    danger: "Perilous when the chest is down"
    sources: "the Codex's gurubashi-arena page"
  - id: stranglethorn-vale-smotts-lifeboat
    tier: off
    object: 2289   # dump 32.5, 82.0; Wowhead 32.4, 81.9
    hint_area: { x: 36.5, y: 81.8, r: 8 }
    danger: "Perilous (the giants)"
    sources: "quests 615, 618, 619"
  - id: stranglethorn-vale-kurzen
    tier: off
    area: Kurzen's Compound   # placed: the client's overlay: 45.4, 9.4
    hint_area: { x: 44.0, y: 11.0, r: 8 }
    danger: "Perilous (Kurzen's men)"
    sources: "quest 202; the Codex's kurzen-rebellion page"
  - id: stranglethorn-vale-poobah
    tier: hidden
    creature: 2634   # Princess Poobah, dump 38.5, 80.6; Wowhead 38.4, 80.6
    hint_area: { x: 36.7, y: 82.3, r: 5 }
    danger: "Perilous (King Mukla's gorillas)"
    sources: "quests 594, 630"
  - id: stranglethorn-vale-emperors-tomb
    tier: hidden
    object: 54   # dump 24.7, 8.9; Wowhead 24.7, 9.0
    hint_area: { x: 26.6, y: 12.4, r: 8 }
    danger: "Perilous (the Bloodscalp)"
    sources: "object 54 (its name); the Codex's gurubashi-empire and zulgurub pages"
  - id: stranglethorn-vale-zanza
    tier: hidden
    reading: Altar of Zanza
    object: 180367   # dump 13.4, 15.1; Wowhead 13.4, 15.1
    hint_area: { x: 15.9, y: 11.9, r: 8 }
    danger: "Quiet"
    sources: "object 180367's text; the Codex's zandalar-tribe page"
  - id: stranglethorn-vale-gromgol
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 2497   # Nimboya, dump 32.2, 27.7; Wowhead 32.2, 27.8
    hint_area: { x: 34.7, y: 27.2, r: 5 }
    danger: "Quiet"
    sources: "quests 581, 592; the Codex's gromgol-base-camp page"
# quarry: the zone's own, in the hunts' pass
---
## stranglethorn-vale-green-hills
At a famous hunter's camp in the north of the jungle,
a dwarf was trusted to proofread his master's novel,
and a gust of wind scattered the pages all over the jungle.
Find the camp, and the dwarf who is still sorry.
? Nesingwary's Expedition, in the north of Stranglethorn.
= Barnil Stonepot, proofreader of The Green Hills of Stranglethorn.
+ 'It shouldn't be long now until we see Master Nesingwary's book in libraries throughout the world!'

## stranglethorn-vale-arena
In the middle of the jungle, a great stone ring the trolls built for blood sports
still fills with fighters: goblins and pirates run it now,
and now and then they throw a chest into the middle.
Be a crowd for them.
? The Gurubashi Arena, in the middle of Stranglethorn, by the road.
= The Gurubashi Arena.
+ Short John Mithril keeps the contests; the fighting outlived the Gurubashi.

## stranglethorn-vale-smotts-lifeboat
On the wild shore, a captain's old lifeboat lies on the sand.
Giants smashed the ship, and one of them went straight for the galley:
he was hungry for wine and barbecued wings, not for the crew.
Find the boat he can be lured to.
? The Wild Shore, south-east of Booty Bay.
= Captain Smotts' lifeboat. Negolash still remembers the galley.
+ The captain lost a second ship, Smotts' Revenge, and a second crew to the same giants, and got the cutlass back only from Negolash.

## stranglethorn-vale-kurzen
In the north of the jungle, a colonel came with a soldier's good name
and changed in the trees, until his men were loyal to him alone
and hunted with a cruelty their old comrades could not stomach.
Find his compound.
? Kurzen's Compound, in the north-east of Stranglethorn.
= Kurzen's Compound. The rebels who would not follow him hold a camp to the north.
+ 'None had the cruel intellect of Kurzen,' says Lieutenant Doren, whose rebels he hunted.

## stranglethorn-vale-poobah
A message in a bottle washed ashore, in fairly good handwriting:
a princess held captive on an island in the southern sea,
who sees the wild shore to the north-west on the clearest days.
Find its author.
? Jaguero Isle, off Stranglethorn's south coast.
= Princess Poobah, held in chains by King Mukla.
+ 'If it was within my power, I would offer you a place among my tribe.' King Mukla commands the beasts of the island.

## stranglethorn-vale-emperors-tomb
In the north-western ruins of the troll empire that ruled the south
before there were kingdoms of men, a tomb is all that is left
of one of its emperors. Find it.
? The Ruins of Zul'Kunda, in Stranglethorn's north-west.
= The Emperor's Tomb, at Zul'Kunda.
+ The Gurubashi empire once stretched across the south; its descendants hold its ruins now, and Hakkar is back in Zul'Gurub.

## stranglethorn-vale-zanza
On an island off the north-west coast, the oldest tribe of the trolls
has set up an altar to a loa of their faraway home,
and carved a prayer on it for the power to beat the blood god once more.
? Yojamba Isle, off Stranglethorn's north-west coast.
= The Altar of Zanza: 'Give us the power to once more defeat the Blood God.'
+ The Zandalar seldom intervene in other peoples' affairs; Hakkar's return brought them to Yojamba.

## stranglethorn-vale-gromgol
In the Horde's stockade on the northern coast, a troll sent back from the city
searches for his chief's youngest son, given to the old empire by custom
and lost when the tribe left with the young warchief.
Find him.
? Grom'gol Base Camp.
= Nimboya, of the Darkspear.
+ Yenniku is held by Zanzil the Outcast at the Ruins of Aboraz; freed, his tale will be etched in stone 'so that it will live forever'.
