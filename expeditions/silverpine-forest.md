---
zone: 1421   # Silverpine Forest
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: silverpine-forest-corpse-boat
    tier: near
    gestures: [PEER, LOOK]
    object: 1593   # dump 58.4, 34.9; Wowhead 58.4, 34.9
    hint_area: { x: 61.1, y: 31.9, r: 8 }
    danger: "Guarded (Rot Hide gnolls, the dead)"
    sources: "quests 438, 439"
  - id: silverpine-forest-ivar-patch
    tier: off
    area: The Ivar Patch   # placed: Ivar the Foul, dump 51.5, 13.9; Wowhead 51.4, 13.8
    hint_area: { x: 53.8, y: 16.5, r: 7 }
    danger: "Guarded (Ivar the Foul)"
    sources: "quest 425; Ivar the Foul (creature 1971) places the hint"
  - id: silverpine-forest-pyrewood
    tier: off
    night: true
    area: Pyrewood Village   # placed: the client's overlay: 44.9, 73.7, half-size 4.0 by 4.1
    hint_area: { x: 46.0, y: 72.5, r: 7 }
    danger: "Guarded by day; perilous after dark (Moonrage worgen)"
    sources: "quests 99, 452; Archmage Arugal (creature 4275)"
  - id: silverpine-forest-alaric
    tier: hidden
    gestures: [KNEEL, MOURN, PRAY]
    object: 1599   # dump 67.9, 24.9; Wowhead 67.8, 24.8
    hint_area: { x: 70.0, y: 21.5, r: 8 }
    danger: "Perilous (Fenris Keep's dead and gnolls)"
    sources: "quests 460, 461"
  - id: silverpine-forest-sepulcher
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: Yuriv's Tombstone
    object: 24777   # dump 44.1, 42.7; Wowhead 44.2, 42.6
    hint_area: { x: 44.0, y: 46.7, r: 8 }
    danger: "Quiet"
    sources: "object 24777's text; quest 264"
# quarry: the zone's own, in the hunts' pass
---
## silverpine-forest-corpse-boat
At a ferry no one crosses any more,
a boat is heaped with the wrapped dead,
and one hand still wears a ring engraved for someone.
The dead are being carried somewhere; from the boat, you can see where.
? The Decrepit Ferry, on the lake shore east of the Sepulcher; the dead are taken east.
= The ring reads 'For Deliah'. Across the water, a dock on Fenris Isle.
+ The woman was recently killed, and the only such bodies nearby are in Tirisfal's mass graves: the Rot Hide gnolls are carrying them to Fenris Isle.

## silverpine-forest-ivar-patch
In the far north of the pines, a farm and a ghoul share a name.
The ghoul waits in its barn for the guard to drop,
and two scouts of the Forsaken have learned what it does when it does.
Find his patch.
? North of the Sepulcher, near the coast, a pumpkin patch with a keeper.
= The Ivar Patch. Rane and Quinn Yorick came to scout the forest and got no further.
+ 'If you won't do it for me and my brother, then do it for the Forsaken.' Rane Yorick, guarding Quinn while he heals.

## silverpine-forest-pyrewood
South of the keep where an archmage gathers his wolves,
a village goes about its day like any other,
its council at its business, its people at their doors.
Come when the sun is down, and see what they are then.
? Pyrewood Village, south of Shadowfang Keep; by day it shows nothing.
= Pyrewood Village after dark. By day the villagers appear to be human; when the sun goes down they are Moonrage worgen.
+ Arugal keeps the Pyrewood Council as his puppets, to hold the village's wolves in line; a mage at the Sepulcher means to draw on the shackles Arugal cast on them.

## silverpine-forest-alaric
On the island in the lake, near the keep's old stable,
a servant's body lies in an unmarked grave without its head.
His master's spell kept the plague from him, and death with it;
the gnolls dug the grave, and nobody has said a word over it.
? Fenris Isle, in Lordamere Lake: near the keep's stable.
= Alaric, Thule Ravenclaw's head servant. His head is with the gnolls. He asks to be put back together, and to be spared his boots: they never fit.
+ He would rather rest in the keep's hidden alcove: 'I spent the best days of my life in this keep.'

## silverpine-forest-sepulcher
Among the tombs where the Forsaken have made their town,
a paladin's grave once said he would never ask of his children
anything he would not do himself.
Someone has written one word over it since.
? The Sepulcher.
= Yuriv's Tombstone: BETRAYER, crudely scratched over the finely etched epitaph.
+ 'Yuriv lies here. Father, Husband, Paladin.' His widow, Clarice Foster, Forsaken now, sends a pendant back to his tomb: 'Leaves me for his damn crusade... He's dead and I'm bearing the very thing he was trying to stop!'
