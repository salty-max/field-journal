---
zone: 1457   # Darnassus
home: alliance   # a capital: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: darnassus-ainethil
    tier: near
    creature: 4160   # Ainethil, Artisan Alchemist, dump 54.9, 24.0
    found: target   # in the city: only by speaking to her
    hint_area: { x: 55.0, y: 25.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawn and her words; object 175730's text (the first World Tree's blessings)"
  - id: darnassus-darianna
    tier: off
    gestures: [ENCOURAGE, CHEER, GOODLUCK, SMILE]
    creature: 11083   # Darianna, Journeyman Leatherworker, dump 64.4, 20.9; Faldron (11081) her teacher, beside her
    found: target   # in the city: only by speaking to her
    hint_area: { x: 64.5, y: 21.5, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns and their words"
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
## darnassus-ainethil
In the tree city, an alchemist brews the same potion from the same plants, again and again,
and every time it heals a little less. She has drawn the only conclusion she can.
Ask her what it is.
? Darnassus, by the alchemists.
= Ainethil, Artisan Alchemist: 'There can be only one conclusion: the plants are changing. I cannot say why or into what.'
+ The histories in this city tell how three dragons blessed the first World Tree, so that its people would never age nor sicken; of the tree they live in now, they say nothing of the kind.

## darnassus-darianna
On the craftsmen's terrace, a young leatherworker can hardly keep still at her lessons,
and hopes the Sentinels will call her to the front.
Her teacher fears that they will. Wish her well.
? The Craftsmen's Terrace, in Darnassus, among the leatherworkers.
= Darianna, Journeyman Leatherworker: 'Maybe if I'm really lucky, the Sentinels will ask me to join their forces on the front!'
+ Faldron, her teacher: 'With her strength and agility, I fear it won't be long before she is called to fight. We must teach her quickly.'

## darnassus-world-tree
In the tree city, seek the bargain paid in centuries of sleep.
Its keepers would not die of age while the world went on without them.
The price and the promise share a page.
? In the north of Darnassus.
= The World Tree and the Emerald Dream: Nordrassil, 'crown of the heavens'. Three dragons blessed the tree; the night elves received immortality, and their druids agreed to long years of sleep in Ysera's Dream.
+ 'Though the druids were grieved at the prospect of losing so many years of their lives to hibernation, they selflessly agreed to uphold their bargain with Ysera.'

## darnassus-betrayer
Power waited inside an orc warlock's skull.
In the south of the tree city, find the account of the prisoner who took it.
Ten thousand years behind bars had not cured his appetite.
? In the south of Darnassus.
= The Betrayer Ascendant: Illidan, freed from his barrow prison by Tyrande, took the power of the Skull of Gul'dan and later fled to Outland.
+ Maiev Shadowsong, his jailor for ten thousand years, followed him to Outland, determined to bring him to justice.
