---
zone: 1418   # Badlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: badlands-agmond
    tier: near
    gestures: [MOURN, KNEEL, SALUTE]
    object: 2875   # dump 50.9, 62.4; Wowhead 50.9, 62.2
    hint_area: { x: 49.1, y: 58.8, r: 8 }
    danger: "Guarded (troggs, buzzards)"
    sources: "quests 738, 739"
  - id: badlands-hammertoe-map
    tier: off
    object: 2868   # dump 53.0, 33.9; Wowhead 53.0, 34.1
    hint_area: { x: 49.1, y: 34.9, r: 8 }
    danger: "Guarded (the Shadowforge clan)"
    sources: "quests 720, 723; the Codex's hammertoes-digsite page"
  - id: badlands-theldurin
    tier: off
    gestures: [HELLO, GREET, WAVE]
    creature: 2785   # Theldurin the Lost, dump 51.4, 76.9; Wowhead 51.4, 76.8
    hint_area: { x: 49.6, y: 74.5, r: 6 }
    danger: "Guarded"
    sources: "quests 687, 692"
  - id: badlands-seal-of-the-earth
    tier: hidden
    object: 2933   # dump 81.5, 49.9; Wowhead 81.4, 49.8
    hint_area: { x: 77.9, y: 48.2, r: 8 }
    danger: "Perilous (black dragonkin)"
    sources: "quests 782, 793"
  - id: badlands-kargath
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 1068   # Gorn, dump 2.9, 45.6; Wowhead 2.8, 45.8
    hint_area: { x: 1.5, y: 46.6, r: 5 }
    danger: "Quiet"
    sources: "quests 782, 793; the Codex's kargath page"
quarry:
  id: 2745
  sources: "quest 762 (Historian Karnik, Advisor Belgrum)"
---
## badlands-agmond
In a valley of the red waste, a dwarf who ran the League's southern digs
crawled a long way on his own blood,
and with his last strength scratched a name into the sandstone.
Find what the buzzards left of him.
? The Valley of Fangs, in the middle of the Badlands.
= Prospector Agmond, his bones picked clean. Beside his hand, scratched in the sandstone: Murdaloc.
+ Prospector Ironband is sure he took many of the troggs down with him: 'his skull was as thick as they come!'

## badlands-hammertoe-map
At the camp before the titans' vault, the diggers were overrun,
and their leader was carried off by the Dark Irons.
He left one message, in chalk, on a map.
Find it.
? Hammertoe's Digsite, below Uldaman.
= Hammertoe's crumpled map: 'Ryedol, They're taking me to Uldaman. Send help. -Hammertoe'.
+ He was seeking the origins of his people, and stopping the Shadowforge clan from finding the scrolls; his amulet was his life's work.

## badlands-theldurin
At the end of the southern dig, a man who fled a cult of the old gods
hides with a scroll he stole from them, and has lost his mind for it.
He welcomes every visitor many times over.
Find him, and answer in kind.
? Agmond's End, in the south of the Badlands.
= Theldurin the Lost, once of the Twilight's Hammer, who stole the Scroll of Myzrael.
+ 'Hello. Hello, hello hello hello hello HELLO! I'm sorry - wait, no I'm not!' He keeps the scroll so that Myzrael stays beneath Arathi.

## badlands-seal-of-the-earth
In the ravine at the far east of the waste, two black drakes
who served the Destroyer when the Horde was his ally
lie bound under a seal held by three pillars of stone.
Find the seal.
? Lethlor Ravine, at the Badlands' eastern edge.
= The Seal of the Earth, the prison of Blacklash and Hematus.
+ The Horde means to free them only to kill them: 'We must silence our depraved allies of old to restore honor to the Horde!'

## badlands-kargath
In the Horde's stockade on the western cliff, an orc remembers
that the Horde was once the Destroyer's ally,
and wants the dragons it served beside put to death, for its honour.
Find him.
? Kargath.
= Gorn, of the Kargath Expeditionary Force.
+ Boss Tho'grun's ogres, hired to fetch the key to the drakes' prison, betrayed the Horde for it.

## quarry
Ragnaros himself sent an envoy of fire to the fortress in the Badlands,
to mind the Shadowforge who dig for the lost relics of Uldaman.
Their digging has already cost Ironforge dearly.
He keeps to the fortress; the dwarves keep digging.
= Ambassador Infernus, of Angor Fortress. Historian Karnik, in Ironforge, asks for his end, and Advisor Belgrum takes the proof.
+ Once he falls, Belgrum will send aid to the Badlands to take back the excavation site.
