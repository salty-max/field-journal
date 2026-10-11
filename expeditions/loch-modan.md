---
zone: 1432   # Loch Modan
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: loch-modan-valley-of-kings
    tier: near
    gestures: [BOW, SALUTE, KNEEL]
    area: Valley of Kings   # placed: the client's overlay: 20.5, 73.7, half-size 5.5 by 13.8
    hint_area: { x: 22.0, y: 71.0, r: 14 }
    danger: "Quiet"
    sources: "the Codex's valley-of-kings page; object 175739's text"
  - id: loch-modan-ironband
    tier: off
    area: Ironband's Excavation Site   # placed: the client's overlay: 69.4, 65.5, half-size 7.0 by 8.6
    hint_area: { x: 68.0, y: 63.0, r: 10 }
    danger: "Guarded (the Stonesplinter troggs)"
    sources: "quests 297, 436; the Codex's ironbands-excavation-site page"
  - id: loch-modan-suspicious-barrel
    tier: hidden
    gestures: [SNIFF]
    object: 257   # dump 56.1, 13.2; Wowhead 56.1, 13.3
    hint_area: { x: 58.7, y: 16.3, r: 8 }
    danger: "Guarded (Dark Iron sappers)"
    sources: "quests 250, 199"
  - id: loch-modan-thelsamar
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Ironforge - the Awakening of the Dwarves
    object: 175736   # dump 35.5, 49.0; Wowhead's page alike
    hint_area: { x: 33.4, y: 45.6, r: 8 }
    danger: "Quiet"
    sources: "object 175736's text"
# quarry: the zone's own, in the hunts' pass
---
## loch-modan-valley-of-kings
Of three great hammers, two were set in stone.
In life they shared no hall and shared no throne;
their sons set them together by the road,
facing the south, where once the third one's fires glowed.
? In the lake country's south-west, two great figures guard a pass; kings are owed something.
= Bronzebeard and Wildhammer, side by side, raised by their sons. Their peoples parted ways later; the statues did not.
+ The whole war is in a dwarven history, War of the Three Hammers: Thaurissan's summoning woke Ragnaros, and the statues were meant as a warning to all who would attack the dwarven kingdoms, and a reminder of what the Dark Irons paid.

## loch-modan-ironband
The League dug in the southern hills and found strange carved idols,
and before they could study them the troggs came up through the site
and chased them out. The idols drive the troggs berserk.
Find where the League was digging.
? South-east of the Loch, Prospector Ironband's men dug too deep.
= Ironband's Excavation Site. The Explorers' League's own dig, and the troggs' now.
+ Magmar Fellhew wants the idols out of trogg hands, and studied; nobody yet knows why they drive the troggs mad.

## loch-modan-suspicious-barrel
First the great span was blown, then the northern fort pillaged.
Now sappers in dark iron mill about the dam's eastern ramp,
and a barrel stands there that no engineer set down.
What is in it gives itself away before the lid is off.
? The Stonewrought Dam's eastern ramp; whatever is in the barrel is strong.
= A Dark Iron barrel of strange-smelling powder, on the Stonewrought Dam. Chief Engineer Hinderweir was right to worry.
+ Most of the dam's guard was sent to the Alliance front, his top inspector with it; the Dark Irons have noticed.

## loch-modan-thelsamar
In the town on the lake road, a book in the inn tells
how the earth's first children woke in a vault to the south
with soft skin and mortal hearts, and named themselves anew.
? Thelsamar's inn.
= Ironforge - the Awakening of the Dwarves, in Thelsamar. The vault it names, Uldaman, lies south of the Loch, in the Badlands.
+ The dwarves named their land Khaz Modan for the Titan Khaz'goroth, and built a forge for him in the heart of the mountain; the city grew around it.
