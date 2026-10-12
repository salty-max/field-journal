---
zone: 1424   # Hillsbrad Foothills
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: hillsbrad-foothills-zixil
    tier: near
    creature: 3537   # Zixil, Merchant Supreme: from Tarren Mill (dump 62.0, 20.5) to Southshore and back; Overwatch Mark I (3538) linked to him
    found: target   # he never stops walking
    hint_area: { x: 54.0, y: 37.0, r: 6 }
    danger: "Contested (the road between the two towns)"
    sources: "the dump's spawn, path, link (his robot) and wares (one of each at a time); the WoWWiki archive's Overwatch Mark I page; https://www.wowhead.com/classic/item=7148/goblin-jumper-cables (chance to revive a player)"
  - id: hillsbrad-foothills-gryphons
    tier: off
    gestures: [SALUTE, BOW, HAIL]
    creature: 2473   # Granistad, dump 84.3, 32.8; Kurdros (2474) beside him
    hint_area: { x: 82.0, y: 34.5, r: 5 }
    danger: "Deadly to the Horde (two gryphons of Ironforge, level 40); quiet for the Alliance"
    sources: "the WoWWiki archive's Granistad page (the passage to the Hinterlands); the dump's spawns and faction (Ironforge's)"
  - id: hillsbrad-foothills-loving-memory
    tier: hidden
    gestures: [KNEEL, MOURN, PRAY, BOW]
    object: 181062   # dump 67.8, 84.1; Wowhead 67.9, 84.0
    hint_area: { x: 71.5, y: 82.7, r: 8 }
    danger: "Quiet"
    sources: "object 181062's text; the wiki's Dun Garok; the WoWWiki archive's In Loving Memory page (a friend of the developers; Rousch, his character)"
  - id: hillsbrad-foothills-southshore
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Civil War in the Plaguelands
    object: 175761   # dump 51.3, 58.5, by the inn
    hint_area: { x: 50.0, y: 57.0, r: 4 }
    danger: "Quiet"
    sources: "object 175761's text"
  - id: hillsbrad-foothills-tarren-mill
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: Arathor and the Troll Wars
    object: 175734   # dump 62.6, 20.4; Wowhead's page alike
    hint_area: { x: 59.7, y: 17.7, r: 8 }
    danger: "Quiet"
    sources: "object 175734's text"
quarry:
  id: 14277
  sources: "the dump: her spawn on the Eastern Strand among the Daggerspine (faction 74), Scargil's among the Torn Fin"
---
## hillsbrad-foothills-zixil
On the road between two towns that hate each other,
a goblin walks from one to the other and back, all day,
with a robot at his heels, and sells in both:
belts, orbs, a pattern or two, one of each at a time.
Catch him on the road.
? The road from Southshore to Tarren Mill; he walks it end to end.
= Zixil, Merchant Supreme, a goblin who trades in both Southshore and Tarren Mill, with Overwatch Mark I, his robot, at his heels.
+ His schematic teaches an engineer to make Goblin Jumper Cables, which may shock a fallen companion back to life. The word 'may' is worth remembering.

## hillsbrad-foothills-gryphons
Where the road climbs out of the foothills toward the wild dwarves' country,
two gryphons keep the pass, and each of them has a name.
They answer to Ironforge, and they are no friends of the Horde.
Show them a soldier's respect.
? Hillsbrad's north-east corner, where the way climbs toward the Hinterlands.
= Granistad and Kurdros, gryphons of Ironforge, keeping the pass from Hillsbrad up to the Hinterlands.
+ They are of level forty, on a road most travellers climb at twenty-five: for the Horde, not guards so much as a wall.

## hillsbrad-foothills-loving-memory
South of the dwarves' keep, a great stone
keeps a name and two years, and nothing more.
Someone made sure it would be here, for someone they lost.
? Below Dun Garok, toward the sea.
= 'Anthony Ray Stark. 1961 - 2005.'
+ A memorial the world's makers left for a friend of theirs. Rousch, the dwarf standing before it, was his own character in the game; he had brought him to somewhere in the forties.

## hillsbrad-foothills-southshore
A book among the living remembers a rebellion of the dead.
Their new ruler took a ruined capital while their old one hurried north.
Seek the account in the town on the southern shore.
? Southshore, by the inn.
= Civil War in the Plaguelands, in Southshore: how Sylvanas and her Forsaken took the ruins of Lordaeron's capital while Arthas went north.
+ Up the road, the Forsaken hold Tarren Mill: the book's rebels are Southshore's neighbours.

## hillsbrad-foothills-tarren-mill
At the foot of the snowy mountains, the Forsaken keep a page about a hundred human pupils.
Their elven teachers gave them only the magic they needed.
Find what their first great lesson did to an army.
? Tarren Mill.
= Arathor and the Troll Wars, in Tarren Mill: the battle was fought at the foot of the Alterac Mountains.
+ The elves taught a hundred humans the basics of magic, no more than was needed; the trolls never rose as one nation again.

## quarry
Naga have come ashore on the eastern strand of Hillsbrad,
shorestalkers and screamers of the Daggerspine,
and one among them goes by a lady's name.
She keeps to the sand where they landed, and is not always there.
= Lady Zephris, a naga of the Daggerspine. Rarely met: some days she is on the strand, most days not.
+ Up the western strand, Scargil of the Torn Fin murlocs is no easier to find.
