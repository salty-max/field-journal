---
zone: 1441   # Thousand Needles
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: thousand-needles-raceway
    tier: near
    gestures: [CHEER, APPLAUD, CLAP]
    creature: 4507   # Daisy, Race Starter Girl, dump 79.5, 76.9; Fobeed (4620) and Zuzubee (4707) announce
    hint_area: { x: 79.0, y: 77.5, r: 5 }
    danger: "Quiet"
    sources: "the dump's spawns (Daisy, Fobeed, Zuzubee); the WoWWiki archive's Daisy and Fobeed pages"
quarry:
  id: 5933   # Achellios the Banished
  sources: "the WoWWiki archive's Achellios the Banished page (his three hounds); the dump's path"
---
## thousand-needles-raceway
On the salt flats, gnomes and goblins race their machines,
an ogre calls the races, and a barmaid sends them off with a flag.
Every race needs a crowd. Be one.
? The Mirage Raceway, on the Shimmering Flats. Beside the flag-bearer, cheer or applaud the race with an emote.
= Daisy, the race starter girl of the Mirage Raceway, with Fobeed, the ogre, and Zuzubee calling the races.
+ The racers come and go. The flag, the ogre's voice and the salt stay.

## quarry
A centaur called the Banished circles the plateaus of the canyons' west,
between the wyverns' heights and the screeching canyon.
Three hounds keep at his heels.
= Achellios the Banished, a centaur, circling the plateaus between Highperch and the Screeching Canyon with three Galak Packhounds.
+ The Galak's hounds still follow him, whoever it was that banished him.
