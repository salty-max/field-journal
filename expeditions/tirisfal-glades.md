---
zone: 1420   # Tirisfal Glades
home: horde   # a starting zone: its riddles are its faction's alone, as a capital's
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: tirisfal-glades-near
    tier: near
    gesture: KNEEL
    object: 178090   # dump 31.2, 65.1; Wowhead none
    hint_area: { x: 35.1, y: 64.1, r: 8 }
    danger: "Quiet"
    sources: "quest 6395"
    check: "Wowhead has no position for the grave (a quest's object): the dump alone places it, in Deathknell's graveyard; confirm it is visible without the quest"
  - id: tirisfal-glades-off
    tier: off
    area: Agamand Family Crypt   # placed: Captain Dargol, dump 52.8, 26.4; Wowhead 52.4, 26.6
    hint_area: { x: 52.2, y: 23.0, r: 7 }
    danger: "Guarded (Captain Dargol's dead)"
    sources: "quests 354, 361, 362; Captain Dargol (creature 1658) places the hint"
  - id: tirisfal-glades-hidden
    tier: hidden
    gesture: KNEEL
    area: Faol's Rest   # placed: a spirit healer, dump 79.0, 41.0
    hint_area: { x: 80.5, y: 38.5, r: 8 }
    danger: "Perilous (the Scarlet Crusade)"
    sources: "the game's Faol's Rest; Warcraft II: Tides of Darkness's manual (Faol and the Knights of the Silver Hand); object 177199"
    check: "the hint's circle from the spirit healer nearest the monastery (dump 79.0, 41.0); confirm it is Faol's Rest's"
# quarry: the zone's own, in the hunts' pass
---
## tirisfal-glades-near
In the first row of the graveyard where the Forsaken wake,
a woman lies who loved a man the plague made mindless.
He killed her, and her last wish was to lie with him.
Kneel at her grave.
? Deathknell's graveyard, in its first row.
= Marla Fipps. If someone has brought Samuel back from the ruined camp on the road, he lies with her.
+ 'We must respect our dead. It is one of the ways in which we differ from the Scourge.' Novice Elreth, who asks it of the newly risen.

## tirisfal-glades-off
The most prosperous family of the glades fortified their home
when the plague came, and kept their workers at the walls.
The workers died for their pride;
the family's dead were raised in their own crypt. Find it, above the mills.
? North of Brill, above the Agamand Mills.
= The Agamand Family Crypt. Captain Dargol of the Scourge raised its dead; Coleman Farthing, who worked their mills, wants their bones.
+ Thurman Agamand's last letter went to Yvette Farthing, who had begged him to leave with her. Forsaken now, she read it and said love was no longer one of her goals.

## tirisfal-glades-hidden
Near the monastery of the red crusaders,
a resting place bears the name of the archbishop
who gave the Light its first knights.
Kneel there, if the Crusade lets you.
? South-west of the Scarlet Monastery.
= Faol's Rest, in sight of the zealots who claim his Light.
+ Stormwind remembers him too: a plaque in its cathedral calls him the 'benevolent patron of the Church of Light', who began his work in Stratholme and raised the funds to rebuild Stormwind after the Second War.
