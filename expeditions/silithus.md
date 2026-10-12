---
zone: 1451   # Silithus
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: silithus-scarab-wall
    tier: off
    area: The Scarab Wall   # placed: the client's overlay: 28.9, 95.1, half-size 7.0 by 3.0
    hint_area: { x: 30.0, y: 92.0, r: 8 }
    danger: "Perilous (the silithid)"
    sources: "the Codex's the-scarab-wall and the-scepter-of-the-shifting-sands pages"
  - id: silithus-carnes
    tier: off
    gestures: [COMFORT, PAT, SOOTHE, CONGRATULATE, PITY]
    creature: 15903   # Sergeant Carnes, dump 32.6, 51.8, outside Hive'Zora
    hint_area: { x: 32.0, y: 52.0, r: 4 }
    danger: "Perilous (the silithid of Hive'Zora)"
    sources: "the dump's spawn and his words"
  - id: silithus-raloshan
    tier: hidden
    creature: 15169   # Ralo'shan the Eternal Watcher, dump 70.2, 25.3
    found: target   # her story is told by speaking to her
    hint_area: { x: 69.0, y: 26.0, r: 4 }
    danger: "Perilous (the desert's silithid and the Twilight's Hammer)"
    sources: "the dump's spawn and her words; the client's display tables (a night elf); the WoWWiki archive's Ralo'shan page (her dialogue)"
  - id: silithus-glibb
    tier: hidden
    gestures: [WAVE, HELLO, GREET, PET, PAT, SOOTHE]
    creature: 15172   # Glibb, Brann Bronzebeard's Pet Monkey, dump 41.1, 88.6
    hint_area: { x: 41.0, y: 87.0, r: 4 }
    danger: "Perilous (the silithid near the wall)"
    sources: "the dump's spawn and faction (friendly to all); the WoWWiki archive's Glibb page"
quarry:
  id: 14478   # Huricanian
  sources: "the dump's path, kind (an elemental), and the Dust Stormers and Desert Rumblers of the Crystal Vale"
---
## silithus-scarab-wall
At the southern end of the yellow desert stands a wall
raised when the night elves could not win their war against the insects alone,
and a dragon of time sealed it. A gong hangs before it.
Find the wall, and leave the gong alone.
? The Scarab Wall, at the southern edge of Silithus.
= The Scarab Wall, and Ahn'Qiraj behind it.
+ A thousand years ago the qiraji and their silithid swarms came out of Ahn'Qiraj and fell on Kalimdor; the bronze dragon Anachronos made the Scepter of the Shifting Sands to seal them in.

## silithus-carnes
Outside a hive in the yellow desert, a sergeant stands guard among dwarves,
and he has a few things to say about the promotion that put him there.
Hear him out, and be kind.
? Outside Hive'Zora, in western Silithus.
= Sergeant Carnes: '"Great job collecting resources for the war," they said, "Have a promotion," they said.'
+ 'What they really meant is "You're stationed outside a bughive in Silithus with a bunch of sweaty dwarves, Carnes!" Thanks for the promotion, Captain!'

## silithus-raloshan
On a rise in the desert's north-east stands a woman who says she was here
when the insects first marched out, a thousand years ago,
and that she cannot leave. Ask her how she knows.
? Silithus's north-east; she stands alone.
= Ralo'shan the Eternal Watcher, a night elf: 'I have been slain a hundred times. I always wake here, alive.'
+ 'Some say I am cursed and others... They say that I am blessed: a herald to harken in a new age.'

## silithus-glibb
In the desert's south, a monkey waits in the sand,
the companion of the dwarves' most famous explorer.
The explorer himself is nowhere to be seen. Be friendly to the monkey.
? Silithus's south, east of the Scarab Wall.
= Glibb, Brann Bronzebeard's pet monkey, waiting in the desert without Brann.
+ Nobody in Silithus says where Brann has gone.

## quarry
In the desert's north-west, a storm of an elemental
walks the crystal hollows among the others of its kind.
Seek the air spirit with a name of its own.
= Huricanian, an elemental of the Crystal Vale.
+ The Crystal Vale is where the servants of air and earth gather in Silithus; Huricanian is the one with a name.
