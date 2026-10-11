---
zone: 1420   # Tirisfal Glades
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: tirisfal-glades-solliden
    tier: near
    area: Solliden Farmstead   # placed: the client's overlay: 36.0, 49.5, half-size 7.6 by 6.1
    hint_area: { x: 37.5, y: 48.0, r: 10 }
    danger: "Guarded (the farmers; the Scarlet Crusade)"
    sources: "quests 365, 407"
  - id: tirisfal-glades-agamand-crypt
    tier: off
    area: Agamand Family Crypt   # placed: Captain Dargol, dump 52.8, 26.4; Wowhead 52.4, 26.6
    anchor: { creature: 1658 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 56.3, y: 26.1, r: 7 }
    danger: "Guarded (Captain Dargol's dead)"
    sources: "quests 354, 361, 362; Captain Dargol (creature 1658) places the hint"
  - id: tirisfal-glades-gunther
    tier: off
    object: 1165   # dump 68.0, 42.1; Wowhead 68.0, 42.1
    hint_area: { x: 64.3, y: 43.7, r: 8 }
    danger: "Guarded (Lillith Nefara's altar nearby)"
    sources: "quests 405, 409, 366, 460"
  - id: tirisfal-glades-faols-rest
    tier: hidden
    gestures: [PRAY, KNEEL, BOW]
    area: Faol's Rest   # placed: the server's graveyard 'Tirisfal Glades, Faol's Rest' (world_safe_locs 429): 79.2, 40.9
    anchor: { grave: 429 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 80.5, y: 38.5, r: 8 }
    danger: "Perilous (the Scarlet Crusade)"
    sources: "the game's Faol's Rest; Warcraft II: Tides of Darkness's manual (Faol and the Knights of the Silver Hand); object 177199"
quarry:
  id: 1753
  sources: "quest 398 (Brill's poster)"
---
## tirisfal-glades-solliden
North of the graves where the Forsaken wake, living farmers
still grow pumpkins under the watch of the red crusaders' tower,
and the dead of the town send their newest to steal the harvest.
Find the farm where the living still work.
? The Solliden Farmstead, north of Deathknell.
= The Solliden Farmstead. Its farmers are alive, and want nothing to do with the Forsaken.
+ Apothecary Johaan laces the stolen pumpkins with his latest formula and feeds one to a Scarlet Zealot held in the cellar of Brill's tavern.

## tirisfal-glades-agamand-crypt
The most prosperous family of the glades fortified their home
when the plague came, and kept their workers at the walls.
The workers died for their pride;
the family's dead were raised in their own crypt, above the mills.
? North of Brill, above the Agamand Mills.
= The Agamand Family Crypt. Captain Dargol of the Scourge raised its dead; Coleman Farthing, who worked their mills, wants their bones.
+ Thurman Agamand's last letter went to Yvette Farthing, who had begged him to leave with her. Forsaken now, she read it and said love was no longer one of her goals.

## tirisfal-glades-gunther
On an island in the great lake, a lich keeps his books in a camp,
free of the master who raised him, and sure he was the only one.
An old friend from the mages' city is free as well,
and wants him back. Find the books.
? Gunther's Retreat, the island in Brightwater Lake, north-east of Brill.
= Gunther Arcanus's books, on his island. He, Bethor Iceshard and Thule Ravenclaw studied together in Dalaran.
+ Thule Ravenclaw, the third of those students, serves the Scourge now; it was his spell that gave his servant Alaric the unlife he cannot escape.

## tirisfal-glades-faols-rest
Near the monastery of the red crusaders,
a resting place bears the name of the archbishop
who gave the Light its first knights.
Do there what he taught a kingdom to do, if the Crusade lets you.
? South-west of the Scarlet Monastery, where its fallen come back.
= Faol's Rest, in sight of the zealots who claim his Light.
+ Stormwind remembers him too: a plaque in its cathedral calls him the 'benevolent patron of the Church of Light', who began his work in Stratholme and raised the funds to rebuild Stormwind after the Second War.

## quarry
Even among gnolls, one is called foul:
he steals the dead for the Lich King's army,
and the Forsaken have sentenced him for it.
Look north of Brill, where the gnolls have taken a farm.
= Maggot Eye. The town of Brill pays for his paw, shown to Executor Zygand; mercy, its poster says, is for the weak.
+ What he stole went to the Scourge, whose dead the Forsaken once were.
