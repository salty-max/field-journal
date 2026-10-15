---
zone: 2521   # Zephras Isle
client: forever   # Forever's own: the Skyborne's isle in Skywall, neutral, both of their factions
# the spots, pinned by the data (scripts/expeditions.py resolves them): a creature of Forever's own,
# from the QuestieDB traces where Wowhead's Forever database places it too (one that stands still,
# or found by targeting it), or a sub-area. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: zephras-isle-swimmers
    tier: near
    gestures: [AGREE, NOD]
    creature: 254149   # Sirocca "Swimmers" Starfeather: traces 62.2, 72.8 to 73.3; Wowhead 62.2, 72.8: the Calmbreeze Inn
    found: target   # in the town: only by speaking to him
    hint_area: { x: 62.0, y: 74.0, r: 4 }
    danger: "Quiet"
    sources: "warcraft.wiki.gg's Sirocca Swimmers Starfeather page (his gossip, the innkeeper Donaal Downbreeze); Wowhead Forever's npc=254149 (his words about the forest); the QuestieDB traces and Wowhead (no quest of his)"
  - id: zephras-isle-gustjumpers
    tier: off
    gestures: [LISTEN, APPLAUD, CLAP, DANCE]
    name: The Musical Gustjumpers
    creature: 259006   # a Musical Gustjumper: traces 51.5 to 51.7, 71.8 to 72.2; Wowhead 51.4 and 51.6, 72.2 (a second, 259843, beside it)
    companions: [259843]   # either musical frog is an audience's keeper
    found: target   # it hops about
    hint_area: { x: 51.0, y: 71.0, r: 5 }
    danger: "Guarded (bandits, prideclaws and galestriders about, levels 5 to 10)"
    sources: "Wowhead Forever's npc=259006 and npc=259843 (friendly to both factions; display 6297, Classic's frog) and npc=259005 (the ordinary Gustjumper, neutral); the QuestieDB traces (no quest of theirs)"
  - id: zephras-isle-zendraas
    tier: off
    gestures: [GLARE, SCOWL, FROWN, EYE, DOUBT]
    creature: 272045   # Brother Zendraas: traces 57.8, 52.0 / 58.5, 50.3 / 58.8, 49.6; Wowhead 57.8, 52.0: the Shrine of Akir
    found: target   # among the cult's own: only by speaking to him
    hint_area: { x: 58.0, y: 51.0, r: 4 }
    danger: "Guarded (the cult's own shrine, its zealots of levels 10 and 11)"
    sources: "warcraft.wiki.gg's Brother Zendraas page (his gossip: Falaath Village, the grey robes, a tailor, the windstones); Wowhead Forever's npc=272045 (friendly to both, a vendor; no quest)"
  - id: zephras-isle-thendal-tree
    tier: hidden
    gestures: [LOOK, GAZE, PEER, STARE, POINT]
    name: Haal and Meeri
    creature: 273459   # Haal: traces 41.6, 23.2 and 23.35; Wowhead 41.6, 23.4; Meeri (273460) beside him
    hint_area: { x: 42.5, y: 22.0, r: 4 }
    danger: "Quiet"
    sources: "warcraft.wiki.gg's Haal and Meeri pages (two children atop the tree in Thendal Village, observing a spirit); its On the Shal'nan page (the crystal in the same tree: object 658836, Wowhead 41.9, 23.3); the QuestieDB traces and Wowhead (no quest of theirs); Yala Windwatcher's words (only echoes of the spirits remain)"
quarry:
  id: 256028   # The Lost One
  name: The Lost One
  level: 6
  rank: rareelite
  model: 742188
  sources: "Wowhead Forever's npc=256028 (level 6, rare elite, dragonkin; display 742188) and zone=16593 (the isle's only dragonkin); the QuestieDB traces (four sightings by Windsong Lake; no quest)"
---
## zephras-isle-swimmers
In the inn of the isle's harbour town, a sailor without a ship
insists to the innkeeper, loudly and often, that he saw what he saw.
Nobody in the room believes a word of it.
Take his side.
? The Calmbreeze Inn, in Valanaar. Target the sailor and nod or agree with his story.
= Sirocca 'Swimmers' Starfeather, who sailed the skycutters between the islands before the trouble began, and has been grounded since. He swears that Shadowgale Forest is haunted.
+ What he swears he saw there: windblown wraiths, forest spirits that gnaw at your ankles, and a terrible wraith dressed all in black.

## zephras-isle-gustjumpers
East of the standing stones on the highlands' southern edge,
the isle's little frogs hop through the grass.
Two of them have taken up music.
Give them an audience.
? Between the Overlook Standing Stones and the Gustberry Lowlands, among the gustjumpers. Target either musical frog nearby, then listen, applaud or dance with an emote.
= The Musical Gustjumpers: two frogs of Zephras among the ordinary gustjumpers, and the only two the isle calls musical.
+ The ordinary gustjumpers can be hunted. The two musicians cannot: the isle counts them among its friends.

## zephras-isle-zendraas
In the cult's own shrine, among the grey robes and the shaved heads,
one of the faithful will not lift a hand against you.
He knows what the rest of the isle thinks of that robe.
Let your face show how little you trust that robe.
? The Shrine of Akir, at the heart of the isle. Target the non-hostile cultist and show distrust with a frown or a glare.
= Brother Zendraas, of Falaath Village. When the cult moved in, he shaved his head, put on the grey robes and said the words they wanted to hear. Now he keeps his head down, and survives.
+ He is a tailor, and he designed most of what the cult wears. Bring him spare windstones and he will trade his stock of their robes.

## zephras-isle-thendal-tree
At the top of the tree in Thendal Village,
two children have climbed higher than the grown-ups bother to.
They are watching something the rest of the isle says is gone.
See it with them.
? Thendal Village, in the isle's north-west: up the tree. Climb to the children and look, peer or point with an emote.
= Haal and Meeri, two children of Thendal Village, watching a spirit from the top of the tree. The wind spirits left Zephras long ago. Yala Windwatcher says only their mindless echoes remain.
+ In the same branches, a white crystal keeps a recording, On the Shal'nan: the masked leader of the rebels who fled Eldre'Thalas, who ruled his people for more than a century and then gave his power up to a council.

## quarry
By the lake in the middle of the isle walks a dragonkin,
far stronger than its level: whoever meets it there should not meet it alone.
It has no name, only what it is called.
= The Lost One, an elite dragonkin of level six, by Windsong Lake.
+ Of all the creatures of Zephras Isle, it is the only dragonkin.
