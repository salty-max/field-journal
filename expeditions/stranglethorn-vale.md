---
zone: 1434   # Stranglethorn Vale
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: stranglethorn-vale-booty-bay
    tier: near
    reading: Wrath of Soulflayer
    object: 175856   # dump 27.8, 77.3, in Booty Bay
    hint_area: { x: 27.0, y: 76.0, r: 4 }
    danger: "Quiet"
    sources: "object 175856's text"
  - id: stranglethorn-vale-brutus
    tier: off
    gestures: [SALUTE, HAIL, WAVE, GREET, BOW]
    creature: 2551   # Brutus, dump 32.9, 88.3, at the helm of the easternmost Bloodsail ship
    hint_area: { x: 33.0, y: 86.0, r: 5 }
    danger: "Perilous (the Bloodsail crews aboard, levels 40 to 45; deep water)"
    sources: "the WoWWiki archive's Brutus and Ironpatch pages (the golem at Stillwater's helm; an orc of the Bloodsail); the dump's spawns"
  - id: stranglethorn-vale-emperors-tomb
    tier: hidden
    object: 54   # dump 24.7, 8.9; Wowhead 24.7, 9.0
    hint_area: { x: 26.6, y: 12.4, r: 8 }
    danger: "Perilous (the Bloodscalp)"
    sources: "object 54 (its name); the Codex's gurubashi-empire and zulgurub pages"
  - id: stranglethorn-vale-gromgol
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 3149   # Nez'raz, Zeppelin Master, dump 31.4, 29.9, atop the tower
    found: target   # in the town: only by speaking to him
    hint_area: { x: 32.0, y: 28.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and his words"
quarry:
  id: 14490   # Rippa
  sources: "the WoWWiki archive's Rippa page (a frenzy with a name); the dump's paths (round the southern tip, into Booty Bay's harbour) and respawn (12 to 24 hours)"
---
## stranglethorn-vale-booty-bay
In the pirates' port at the jungle's tip, a history tells how the trolls of this jungle
bargained with a god of blood and fed him souls, then turned on him,
and drove the priests who kept faith with him north into the swamps.
? Booty Bay.
= Wrath of Soulflayer, in Booty Bay: Hakkar, the blood god the Gurubashi served and then cast out.
+ The Darkspear were among the tribes that went their own way after that war; and some spoke of a prophecy, that Hakkar would one day be reborn and consume the world whole.

## stranglethorn-vale-brutus
Off the jungle's southern tip, the pirates of the Bloodsail ride at anchor,
and at the wheel of the easternmost ship stands no pirate at all,
but a thing of iron that does not sleep.
Show the helmsman a sailor's courtesy.
? Out at sea, south-east of Booty Bay, aboard the Bloodsail fleet.
= Brutus, a golem, at the helm of the easternmost ship of the Bloodsail fleet, Captain Stillwater's.
+ On the next ship west, an orc called Ironpatch sails with the Bloodsail too: the Buccaneers take their crews where they find them.

## stranglethorn-vale-emperors-tomb
In the north-western ruins of the troll empire that ruled the south
before there were kingdoms of men, a tomb is all that is left
of one of its emperors. Find it.
? The Ruins of Zul'Kunda, in Stranglethorn's north-west.
= The Emperor's Tomb, at Zul'Kunda.
+ The Gurubashi empire once stretched across the south; its descendants hold its ruins now, and Hakkar is back in Zul'Gurub.

## stranglethorn-vale-gromgol
At the top of the Horde's tower in the jungle, a goblin sees the airships off to Orgrimmar,
and has been left at the wrong end of the route.
He would give a great deal for a decent meal from home. Ask him.
? Grom'gol Base Camp, at the top of the zeppelin tower.
= Nez'raz, Zeppelin Master at Grom'gol: his brother talked him into the trade route, and left him the jungle end of it.
+ 'If you come back this way on the Zeppelin, could you bring me something to eat? ... I sure could use something that didn't die weeks before it stopped moving.'

## quarry
In the warm shallows round the jungle's southern tip, the frenzies are many and small,
and one of them is big enough to have a name.
It swims the coast, and now and then into the pirates' harbour itself.
= Rippa, a frenzy of the shore around Booty Bay: a fish with a name, of all things.
+ Kill it, and half a day to a whole day passes before it swims again.
