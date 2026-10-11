---
zone: 1432   # Loch Modan
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: loch-modan-near
    tier: near
    gesture: SALUTE
    area: Valley of Kings   # placed: the client's overlay: 20.5, 73.7, half-size 5.5 by 13.8
    hint_area: { x: 22.0, y: 71.0, r: 14 }
    danger: "Quiet"
    sources: "the Codex's valley-of-kings page; object 175739's text"
  - id: loch-modan-off
    tier: off
    area: Ironband's Excavation Site   # placed: the client's overlay: 69.4, 65.5, half-size 7.0 by 8.6
    hint_area: { x: 68.0, y: 63.0, r: 10 }
    danger: "Guarded (the Stonesplinter troggs)"
    sources: "quests 297, 436; the Codex's ironbands-excavation-site page"
  - id: loch-modan-hidden
    tier: hidden
    object: 257   # dump 56.1, 13.2; Wowhead 56.1, 13.3
    hint_area: { x: 60.1, y: 12.9, r: 8 }
    danger: "Guarded (Dark Iron sappers)"
    sources: "quests 250, 199"
# quarry: the zone's own, in the hunts' pass
---
## loch-modan-near
Of three great hammers, two were set in stone.
In life they shared no hall and shared no throne;
their sons set them together by the road,
facing the south, where once the third one's fires glowed.
? In the lake country's south-west, two great figures guard a pass.
= Bronzebeard and Wildhammer, side by side, raised by their sons. Their peoples parted ways later; the statues did not.
+ The whole war is in a dwarven history, War of the Three Hammers: Thaurissan's summoning woke Ragnaros, and the statues were meant as a warning to all who would attack the dwarven kingdoms, and a reminder of what the Dark Irons paid.

## loch-modan-off
The League dug in the southern hills and found strange carved idols,
and before they could study them the troggs came up through the site
and chased them out. The idols drive the troggs berserk.
Find where the League was digging.
? South-east of the Loch, Prospector Ironband's men dug too deep.
= Ironband's Excavation Site. The Explorers' League's own dig, and the troggs' now.
+ Magmar Fellhew wants the idols out of trogg hands, and studied; nobody yet knows why they drive the troggs mad.

## loch-modan-hidden
First the great span was blown, then the northern fort pillaged.
Now sappers in dark iron mill about the dam's eastern ramp,
and a barrel stands there that no engineer set down.
Find it, and smell the powder.
? The Stonewrought Dam's eastern ramp.
= A Dark Iron barrel of strange-smelling powder, on the Stonewrought Dam. Chief Engineer Hinderweir was right to worry.
+ Most of the dam's guard was sent to the Alliance front, his top inspector with it; the Dark Irons have noticed.
