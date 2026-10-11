---
zone: 1424   # Hillsbrad Foothills
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: hillsbrad-foothills-near
    tier: near
    area: Durnholde Keep   # placed: the client's overlay: 76.8, 40.8, half-size 6.5 by 7.9
    hint_area: { x: 75.0, y: 43.0, r: 10 }
    danger: "Guarded (the Syndicate)"
    sources: "the Codex's durnholde-keep page; Warcraft: Lord of the Clans (2000)"
  - id: hillsbrad-foothills-off
    tier: off
    object: 1727   # dump 72.4, 79.8 (six kegs); Wowhead 71.4-72.7, 80.0-81.0
    hint_area: { x: 74.1, y: 76.2, r: 8 }
    danger: "Guarded (the dwarves of Dun Garok; perilous for the Horde)"
    sources: "quests 517, 541"
  - id: hillsbrad-foothills-hidden
    tier: hidden
    reading: In Loving Memory
    gesture: KNEEL
    object: 181062   # dump 67.8, 84.1; Wowhead 67.9, 84.0
    hint_area: { x: 69.2, y: 80.3, r: 8 }
    danger: "Quiet"
    sources: "object 181062's text; the wiki's Dun Garok"
# quarry: the zone's own, in the hunts' pass
---
## hillsbrad-foothills-near
A lord raised an orphan of his foes to fight,
a champion in chains, a weapon held tight.
A girl of the household helped the young slave go free;
he came back with his people, and the lord ceased to be.
The walls are a thieves' den now. Walk them, and see.
? East of the foothills' road, where the internment camps were ruled.
= Durnholde, where Blackmoore kept the boy he called Thrall. The Syndicate holds it now, a poorer use of a fortress.
+ Taretha Foxton's pendant went to a manor by Lordamere Lake, and Thrall's agents brought it home.

## hillsbrad-foothills-off
In the south-eastern hills, dwarves keep a barracks
to help the humans in their war, and a stout in kegs
that a Forsaken apothecary wants for a test of his plague.
Find the kegs.
? Dun Garok, along Thoradin's Wall in Hillsbrad's south-east.
= Shindigger Stout, at Dun Garok.
+ Apothecary Lydon of Tarren Mill thinks a plague is wasted on a frog or a dog.

## hillsbrad-foothills-hidden
South of the dwarves' keep, a small stone
keeps a name and two years, and nothing more.
Someone made sure it would be here.
Read it, and kneel.
? Below Dun Garok, toward the sea.
= 'Anthony Ray Stark. 1961 - 2005.'
+ A memorial the world's makers left for a friend of one of them.
