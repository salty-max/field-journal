---
zone: 1437   # Wetlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: wetlands-sundown-marsh
    tier: off
    gestures: [HELLO, GREET, WAVE]
    creature: 2679   # Wenna Silkbeard, dump 25.6, 25.8; Fradd Swiftgear (2682) beside her
    hint_area: { x: 24.0, y: 28.0, r: 6 }
    danger: "Guarded (crocolisks, bog beasts and raptors all round)"
    sources: "the WoWWiki archive's Sundown Marsh page (the stone house, the windmill); the dump's spawns and wares (one piece at a time; Fradd's plans half a day to return); the client's display tables (a dwarf, a gnome)"
  - id: wetlands-terl
    tier: hidden
    creature: 2153   # Terl Arakor, dump 27.4, 41.2
    found: target
    hint_area: { x: 29.0, y: 39.0, r: 5 }
    danger: "Guarded (Mottled raptors); for the Horde, Terl himself"
    sources: "the dump's spawn, his words and his faction (the Alliance's, hostile to the Horde)"
  - id: wetlands-menethil
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Battle of Grim Batol
    object: 175750   # dump 10.8, 60.8; Wowhead's page alike
    hint_area: { x: 9.0, y: 64.4, r: 8 }
    danger: "Quiet"
    sources: "object 175750's text"
quarry:
  id: 1140   # Razormaw Matriarch
  sources: "the WoWWiki archive's Razormaw Matriarch and Raptor Ridge pages (her brood, the cavern); the dump's path and respawn (32 to 48 hours)"
---
## wetlands-sundown-marsh
Deep in the marsh, where the crocolisks own the water,
a dwarf and a gnome keep a stone house with a windmill,
and sell what they come by: fine belts and leggings, one of each at a time,
and two gnomish plans, one copy of each.
Call at their door.
? Sundown Marsh, the Wetlands' north-west, west of Ironbeard's Tomb.
= Wenna Silkbeard, a dwarf, and Fradd Swiftgear, a gnome, in their stone house in Sundown Marsh. Fradd's plans: a Lovingly Crafted Boomstick and a Minor Recombobulator.
+ Once sold, Fradd's plans take half a day to come back; Wenna's armour, two and a half to three hours; her patterns, twenty minutes to an hour.

## wetlands-terl
North of the old dig, out in the marsh where the raptors hunt,
a man stands alone, and he is not going anywhere.
Ask him what he is doing there. He has an answer, and he will shout it.
? Black Channel Marsh's north edge, north of Whelgar's Excavation Site.
= Terl Arakor, alone in the marsh: 'This is MY WAGON! MINE!'
+ He stands with the Alliance: a Horde traveller gets no answer from him, only a fight.

## wetlands-menethil
In the harbour town, a history tells of the mountain
at the far end of the marsh: the orcs who held the Dragonqueen there,
and how her dragons tore the fortress apart when she was free.
? Menethil Harbor.
= The Battle of Grim Batol, in Menethil Harbor. The mountain it tells of stands at the Wetlands' eastern edge.
+ Grim Batol was a Wildhammer stronghold first, 'some say cursed'; a small band led by the mage Rhonin destroyed the Demon Soul and freed Alexstrasza.

## quarry
In the Wetlands' east, a ridge of raptors has a cavern,
and in it the mother of them all watches over her brood.
Kill her, and a day and a half will pass at the least before she is back;
two days, at the most.
= The Razormaw Matriarch, level 31, in the cavern of Raptor Ridge, with her Highland and Elder Razormaws.
+ She keeps to the cavern and the slope before it, never far from her brood.
