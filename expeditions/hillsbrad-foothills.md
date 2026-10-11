---
zone: 1424   # Hillsbrad Foothills
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: hillsbrad-foothills-durnholde
    tier: near
    area: Durnholde Keep   # placed: the client's overlay: 76.8, 40.8, half-size 6.5 by 7.9
    hint_area: { x: 75.0, y: 43.0, r: 10 }
    danger: "Guarded (the Syndicate)"
    sources: "the Codex's durnholde-keep page; Warcraft: Lord of the Clans (2000)"
  - id: hillsbrad-foothills-shindigger
    tier: off
    gestures: [CHUG, DRINK, TOAST]
    object: 1727   # dump 72.4, 79.8 (six kegs); Wowhead 71.4-72.7, 80.0-81.0
    hint_area: { x: 68.7, y: 81.4, r: 8 }
    danger: "Guarded (the dwarves of Dun Garok; perilous for the Horde)"
    sources: "quests 517, 541"
  - id: hillsbrad-foothills-loving-memory
    tier: hidden
    gestures: [KNEEL, MOURN, PRAY, BOW]
    object: 181062   # dump 67.8, 84.1; Wowhead 67.9, 84.0
    hint_area: { x: 71.5, y: 82.7, r: 8 }
    danger: "Quiet"
    sources: "object 181062's text; the wiki's Dun Garok"
  - id: hillsbrad-foothills-southshore
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 2711   # Phin Odelic, dump 50.3, 59.0; Wowhead 50.2, 58.8
    hint_area: { x: 47.8, y: 59.0, r: 5 }
    danger: "Quiet"
    sources: "quests 659, 657, 661"
  - id: hillsbrad-foothills-tarren-mill
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: Arathor and the Troll Wars
    object: 175734   # dump 62.6, 20.4; Wowhead's page alike
    hint_area: { x: 59.7, y: 17.7, r: 8 }
    danger: "Quiet"
    sources: "object 175734's text"
# quarry: the zone's own, in the hunts' pass
---
## hillsbrad-foothills-durnholde
A lord raised an orphan of his foes to fight,
a champion in chains, a weapon held tight.
A girl of the household helped the young slave go free;
he came back with his people, and the lord ceased to be.
The walls are a thieves' den now. Walk them, and see.
? East of the foothills' road, where the internment camps were ruled.
= Durnholde, where Blackmoore kept the boy he called Thrall. The Syndicate holds it now, a poorer use of a fortress.
+ Taretha Foxton's pendant went to a manor by Lordamere Lake, and Thrall's agents brought it home.

## hillsbrad-foothills-shindigger
In the south-eastern hills, dwarves keep a barracks
to help the humans in their war, and a stout in kegs
that a Forsaken apothecary wants for a test of his plague.
The kegs deserve a better use than his.
? Dun Garok, along Thoradin's Wall in Hillsbrad's south-east; the stout is good.
= Shindigger Stout, at Dun Garok.
+ Apothecary Lydon of Tarren Mill thinks a plague is wasted on a frog or a dog.

## hillsbrad-foothills-loving-memory
South of the dwarves' keep, a small stone
keeps a name and two years, and nothing more.
Someone made sure it would be here, for someone they lost.
? Below Dun Garok, toward the sea.
= 'Anthony Ray Stark. 1961 - 2005.'
+ A memorial the world's makers left for a friend of one of them.

## hillsbrad-foothills-southshore
In the town on the southern shore, a man who gathered friends after the plague
sends them into the hills to learn what the dead are brewing:
a cousin's dog grew to monstrous size and had to be put down.
Find him.
? Southshore.
= Phin Odelic. His companions Quae and Kinelory watch a farm in Arathi for him.
+ 'He's done so much for us since the plague. We never thought we'd find friends or family again.'

## hillsbrad-foothills-tarren-mill
In the Forsaken's mill town, at the foot of the snowy mountains,
a history tells of the battle fought at their feet long ago:
the first human magi and the elves against the troll armies.
? Tarren Mill.
= Arathor and the Troll Wars, in Tarren Mill: the battle was fought at the foot of the Alterac Mountains.
+ The elves taught a hundred humans the basics of magic, no more than was needed; the trolls never rose as one nation again.
