---
zone: 1428   # Burning Steppes
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: burning-steppes-thaurissan
    tier: near
    area: Ruins of Thaurissan   # placed: the client's overlay: 65.1, 34.4, half-size 10.2 by 12.7
    hint_area: { x: 63.0, y: 33.0, r: 12 }
    danger: "Perilous (the Blackrock and their beasts)"
    sources: "the Codex's ruins-of-thaurissan page; object 175739's text; quest 4296"
  - id: burning-steppes-altar-of-storms
    tier: off
    area: Altar of Storms   # placed: the client's overlay: 15.7, 32.2, half-size 5.7 by 9.7
    hint_area: { x: 17.0, y: 30.0, r: 10 }
    danger: "Perilous (Blackrock warlocks)"
    sources: "the Codex's altar-of-storms page"
  - id: burning-steppes-cyrus
    tier: hidden
    creature: 9459   # Cyrus Therepentous, dump 95.1, 31.6; Wowhead 95.0, 31.4
    hint_area: { x: 97.4, y: 30.7, r: 5 }
    danger: "Perilous (black dragonkin)"
    sources: "quests 4022, 4023"
  - id: burning-steppes-morgans-vigil
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 9560   # Marshal Maxwell, dump 84.7, 69.0; Wowhead 84.6, 68.8
    hint_area: { x: 83.8, y: 66.7, r: 5 }
    danger: "Quiet"
    sources: "quests 4183-4224; the Codex's morgans-vigil page"
  - id: burning-steppes-flame-crest
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 9536   # Maxwort Uberglint, dump 65.2, 23.9; Wowhead 65.2, 23.8
    hint_area: { x: 67.7, y: 23.9, r: 5 }
    danger: "Quiet"
    sources: "quest 4296"
quarry:
  id: 8977
  sources: "quest 3822 (Sha'ni Proudtusk, Thal'trak)"
---
## burning-steppes-thaurissan
On a plain of ash that was once green mountains, a city of dark iron lies broken.
Its sorcerer-king and seven of his greatest went down
to call on what slept beneath the world, to turn a war,
and fire answered. Walk the ruins.
? The Ruins of Thaurissan, in the east of the Burning Steppes.
= The Ruins of Thaurissan, the Dark Iron capital the Firelord destroyed.
+ A fortune hunter at Flame Crest is after the Tablet of the Seven, sure that knowledge and power bring wealth.

## burning-steppes-altar-of-storms
In the shadow of the black mountain, an altar of the old Horde's warlocks still stands,
where magic once made ogres cunning and taught them spells.
Warlocks still gather there. Find the altar.
? The Altar of Storms, in the west of the Burning Steppes, under Blackrock Spire.
= The Altar of Storms. Mor'zul Bloodbringer camps beside it.
+ In the Second War, rites worked at such altars turned ogres into ogre magi.

## burning-steppes-cyrus
At the far end of the path the black drakes fly,
someone waits who speaks for the Flight,
and has already decided that you are unworthy.
Find the Flight's voice anyway.
? The Terror Wing Path, at the Burning Steppes' north-east edge.
= Cyrus Therepentous, who speaks for the black dragonflight.
+ 'You have proven that you are not entirely useless, mortal.' The warmest words on offer.

## burning-steppes-morgans-vigil
In a burned village between the dark horde and the lake town,
soldiers have proof that dragons drive the orcs,
and the city they serve keeps asking for more proof.
Find their marshal.
? Morgan's Vigil.
= Marshal Maxwell, at Morgan's Vigil.
+ 'What? You thought you were the first? How many soldiers must we lose before Stormwind acts?'

## burning-steppes-flame-crest
At the camp on the crest above the ruins, a fortune hunter
follows the legend of seven dwarves of great power,
sure that wherever there is knowledge, wealth follows.
Find him.
? Flame Crest.
= Maxwort Uberglint, after the Tablet of the Seven.
+ 'If we can learn more of the Seven, then maybe we can get rich together.'

## quarry
A soldier from Kargath came with her platoon to these burning lands,
and the ogres of the great rock took them all.
Their leader kept her alive for a ritual, chained at his altar,
and wears her wedding nose-ring on his finger. Search his caves.
= Krom'Grul, of Dreadmaul Rock. The spirit of Sha'ni Proudtusk, chained at his altar, asks for her ring to go back to Thal'trak in Kargath.
+ They were going to move to the Hinterlands; it was to be her last mission. Thal'trak does not want the ring: not without her.
