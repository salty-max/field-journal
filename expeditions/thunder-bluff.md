---
zone: 1456   # Thunder Bluff
home: horde   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: thunder-bluff-cairne
    tier: near
    gestures: [BOW, SALUTE]
    creature: 3057   # Cairne Bloodhoof, dump 60.3, 51.7; Wowhead 59.8, 51.6
    hint_area: { x: 58.3, y: 51.6, r: 4 }
    danger: "Quiet"
    sources: "the Codex's cairne-bloodhoof page"
  - id: thunder-bluff-white-stag
    tier: off
    reading: The White Stag and the Moon
    object: 177208   # dump 78.7, 26.6; Wowhead's page alike
    hint_area: { x: 74.7, y: 26.4, r: 8 }
    danger: "Quiet"
    sources: "object 177208's text"
  - id: thunder-bluff-pools-of-vision
    tier: hidden
    creature: 3419   # Apothecary Zamah, dump 22.8, 20.9; Wowhead 23.0, 21.0
    hint_area: { x: 20.8, y: 20.8, r: 4 }
    danger: "Quiet"
    sources: "quest 853"
# no quarry: a capital has riddles alone
---
## thunder-bluff-cairne
On the high mesas of the plains, the old chieftain who built this city
and gave his people a home for the first time in their memory
speaks slowly and seldom. Honour him as his people do.
? Thunder Bluff, in the High Chieftain's lodge.
= Cairne Bloodhoof, High Chieftain of the tauren.
+ When Thrall's orcs came ashore, Cairne was leading his people across the plains with the centaur at their heels, and the orcs fought beside them.

## thunder-bluff-white-stag
On the rise of the elders, a tale tells of a white stag
whose antlers tangled in the stars as he fled the hunters,
and of the moon, who freed him for his love. Find the tale.
? Elder Rise.
= The White Stag and the Moon: Apa'ro, whom the night elves call Malorne.
+ Their child was Cenarius, who 'would walk the starry path between the waking world and the kingdom of the heavens'.

## thunder-bluff-pools-of-vision
Beneath the rise of the spirit-speakers, a hidden path leads down
to still water where visions are sought,
and the dead of the ruined kingdom keep an apothecary there. Find her.
? The path is well hidden, on the Spirit Rise bluff.
= The Pools of Vision, and Apothecary Zamah of the Royal Apothecary Society.
+ 'She is in the Pools of Vision, a cave beneath the shamans of Thunder Bluff. The path to this cave is well hidden, but you may find it on the Spirit Rise bluff.'
