---
zone: 1457   # Darnassus
home: alliance   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: darnassus-tyrande
    tier: near
    gestures: [BOW, KNEEL]
    creature: 7999   # Tyrande Whisperwind, dump 39.1, 81.6; Wowhead 39.0, 81.6
    hint_area: { x: 41.1, y: 81.8, r: 4 }
    danger: "Quiet"
    sources: "the Codex's tyrande-whisperwind page"
  - id: darnassus-world-tree
    tier: off
    reading: The World Tree and the Emerald Dream
    object: 175730   # dump 56.2, 4.0; Wowhead's page alike
    hint_area: { x: 59.8, y: 5.7, r: 8 }
    danger: "Quiet"
    sources: "object 175730's text"
  - id: darnassus-betrayer
    tier: hidden
    reading: The Betrayer Ascendant
    object: 175759   # dump 66.5, 76.6; Wowhead's page alike
    hint_area: { x: 69.2, y: 73.6, r: 8 }
    danger: "Quiet"
    sources: "object 175759's text; the Codex's tyrande-whisperwind page"
# no quarry: a capital has riddles alone
---
## darnassus-tyrande
In the temple of the moon in the tree city, the high priestess
who fought the Legion ten thousand years ago and woke the sleeping druids
leads her people while their arch druid is missing.
Come before her as she is owed.
? The Temple of the Moon, in the Temple Gardens.
= Tyrande Whisperwind, High Priestess of Elune.
+ Malfurion is missing, and the druids do not know his fate; Fandral Staghelm heads them meanwhile.

## darnassus-world-tree
A history in the tree city tells how three dragons blessed a tree
grown from an acorn in a well of magic, so that its people would never grow old,
and how its druids agreed to sleep for centuries in return.
? In the north of Darnassus.
= The World Tree and the Emerald Dream: Nordrassil, 'crown of the heavens'.
+ 'Though the druids were grieved at the prospect of losing so many years of their lives to hibernation, they selflessly agreed to uphold their bargain with Ysera.'

## darnassus-betrayer
In the tree city, a history tells of the high priestess's other admirer,
freed after ten thousand years in his barrow,
who took a demon's skull for its power and fled to the remains of the orcs' world.
? In the south of Darnassus.
= The Betrayer Ascendant: Illidan.
+ Maiev Shadowsong, his jailor for ten thousand years, followed him to Outland, determined to bring him to justice.
