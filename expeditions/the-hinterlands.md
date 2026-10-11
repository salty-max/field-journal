---
zone: 1425   # The Hinterlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: the-hinterlands-rhapsody
    tier: near
    gestures: [HICCUP]
    creature: 5634   # Rhapsody Shindigger, dump 26.9, 48.6; Wowhead 26.8, 48.6
    hint_area: { x: 28.5, y: 46.7, r: 5 }
    danger: "Quiet"
    sources: "quest 1469"
  - id: the-hinterlands-oox
    tier: off
    creature: 7806   # OOX-09/HL, dump 49.4, 37.7; Wowhead 49.4, 37.6 (it walks only when escorted)
    hint_area: { x: 50.3, y: 35.4, r: 5 }
    danger: "Guarded (forest trolls)"
    sources: "quest 485"
  - id: the-hinterlands-atalai-exile
    tier: off
    creature: 5598   # the Atal'ai Exile, dump 33.8, 75.2; Wowhead 33.6, 75.2
    hint_area: { x: 32.7, y: 77.4, r: 5 }
    danger: "Perilous (the Witherbark)"
    sources: "quest 1429; the Codex's shadra page"
  - id: the-hinterlands-cortello
    tier: hidden
    object: 2556   # dump 80.8, 46.8; Wowhead 80.8, 46.8
    hint_area: { x: 81.2, y: 42.8, r: 8 }
    danger: "Guarded (the deep)"
    sources: "quests 624, 625, 626"
  - id: the-hinterlands-aerie-peak
    tier: town
    faction: alliance   # its town's: for that faction alone
    gestures: [BOW, SALUTE]
    creature: 5635   # Falstad Wildhammer, dump 11.8, 46.8; Wowhead 11.8, 46.8
    hint_area: { x: 9.8, y: 45.3, r: 5 }
    danger: "Quiet"
    sources: "the Codex's falstad-wildhammer and wildhammer-clan pages; object 175739's text"
  - id: the-hinterlands-revantusk
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [COMFORT, SOOTHE]
    creature: 14736   # Primal Torntusk, dump 78.2, 81.2; Wowhead 78.2, 81.2
    hint_area: { x: 79.3, y: 78.9, r: 5 }
    danger: "Quiet"
    sources: "quest 7845; the Codex's revantusk-village page"
quarry:
  id: 7977
  sources: "quests 7816 (Katoom the Angler), 2941 (Daryn Lightwind)"
---
## the-hinterlands-rhapsody
At the high elves' lodge in the western hills, a dwarf rider
drank a whole keg of stout before a flight, fell off his gryphon into a sunken temple's pool,
and swam out of a nest of trolls with a souvenir.
He has not quite recovered, and it shows when he talks. Answer him the same way.
? Quel'Danil Lodge, in the west of the Hinterlands; the stout has not quite worn off.
= Rhapsody Shindigger, who knew where the sunken temple was all along.
+ 'Didn't see no temple till I got a little too tipsy and fell off my mount. Hiccup!' Brohann Caskbelly, in Stormwind, would have saved some leg work by asking him.

## the-hinterlands-oox
At the head of the river in the troll ruins, a gnome's homing robot
crashed, shaped like an egg and a chicken, and lies waiting
for someone to bring it a beacon and watch over its long walk home.
Find where it fell.
? Agol'watha, near Skulk Rock, at the head of the river.
= Homing Robot OOX-09/HL, Oglethorpe Obnoticus's.
+ 'You place the egg... distress beacon... inside the chicken... homing robot.'

## the-hinterlands-atalai-exile
Among the spider-worshipping trolls of the southern hills lives a priest
of the sunken temple's tribe, sentenced to a fate worse than death:
to live far from his people, with these. Find him.
? Shadra'Alor, in the south of the Hinterlands.
= The Atal'ai Exile.
+ His sentence was written in blood on dried flesh. He still wonders whether Hakkar has returned to the temple.

## the-hinterlands-cortello
Someone named Cortello left a riddle in three parts across two continents,
from a bridge in the swamp to a cave in the marsh,
and the last part sends the solver to the coast of these hills,
to the foot of the great falls, under the water. Find what it calls.
? On the Hinterlands' east coast, at the base of the great falls.
= Cortello's Treasure, the end of Cortello's Riddle.
+ 'Along the coast of the Hinterlands, at the base of the great falls / Underneath the water there does your treasure call!'

## the-hinterlands-aerie-peak
In the town of gryphon roosts on the western crag,
the high thane of the third hammer rules his own people,
who left their cursed fortress long ago for the open sky.
Honour him as a thane is honoured.
? Aerie Peak.
= High Thane Falstad Wildhammer.
+ The Wildhammer left Grim Batol when the Dark Iron queen Modgud's death left a darkness in its stone, and went north.

## the-hinterlands-revantusk
In the troll village on the eastern coast, a tribe's matriarch
had her mate taken in a midnight raid by a larger tribe,
to be given to the blood god on the top of their temple.
Find her.
? Revantusk Village.
= Primal Torntusk. Her mate, Elder Torntusk, is held atop Jintha'Alor for the Vile Priestess Hexx.
+ 'You must save him! Our village could not stand a loss this great.'

## quarry
On the coast below the cliffs, among the saltwater snapjaws,
one turtle leads the rest: a giant, and a thief.
She snapped an angler's best lure right off the line, and has it still.
A historian would like a picture of her too.
= Gammerita. Katoom the Angler, at Revantusk Village, wants the lure back from her stomach.
+ Daryn Lightwind, a historian who studies the snapjaws, sends her interns with an invention that captures a picture: a snapshot, she calls it.
