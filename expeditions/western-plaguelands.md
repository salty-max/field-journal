---
zone: 1422   # Western Plaguelands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: western-plaguelands-uthers-tomb
    tier: near
    gestures: [KNEEL, SALUTE, PRAY]
    object: 2082   # dump 52.1, 83.3; Wowhead 52.1, 83.2
    hint_area: { x: 55.5, y: 85.4, r: 8 }
    danger: "Quiet"
    sources: "object 2082's text; the Codex's uthers-tomb page"
  - id: western-plaguelands-dalson-diary
    tier: off
    object: 175926   # dump 47.8, 50.7; Wowhead 47.8, 50.7
    hint_area: { x: 51.4, y: 52.5, r: 8 }
    danger: "Perilous (the farm's dead, a cauldron nearby)"
    sources: "quests 5058, 5059"
  - id: western-plaguelands-felstone
    tier: off
    creature: 10778   # Janice Felstone, dump 38.4, 54.1; Wowhead 38.4, 54.0
    hint_area: { x: 38.8, y: 57.1, r: 6 }
    danger: "Perilous (the farm's dead, a cauldron nearby)"
    sources: "quests 5021, 5022, 5023"
  - id: western-plaguelands-renfray
    tier: hidden
    creature: 11936   # Artist Renfray, dump 65.8, 75.4; Wowhead 65.6, 75.4
    hint_area: { x: 65.6, y: 72.4, r: 6 }
    danger: "Guarded (the island's ghosts)"
    sources: "quests 5846, 5848; the Codex's caer-darrow page"
  - id: western-plaguelands-chillwind
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 11023   # Weldon Barov, dump 43.5, 83.7; Wowhead 43.4, 83.6
    hint_area: { x: 44.8, y: 81.6, r: 5 }
    danger: "Quiet"
    sources: "quests 5344, 5342; the Codex's house-of-barov page"
# quarry: the zone's own, in the hunts' pass
---
## western-plaguelands-uthers-tomb
On a hill of sorrow in the south of the grey fields,
the first of the Light's knights lies, killed by the student he loved best
while he guarded a king's ashes.
Someone left words over him and did not sign them. Honour him.
? Sorrow Hill, in the south of the Western Plaguelands.
= Uther the Lightbringer's tomb: 'His light is the light of all humanity - and so long as we honor his example, it shall never fade.' - Anonymous.
+ When Arthas came back from Northrend with his cursed sword, Uther stood against him, guarding the urn that held King Terenas's ashes.

## western-plaguelands-dalson-diary
On a farm in the grey fields, a wife dragged her turned husband
into the only place she could find that would lock tight,
and wrote it all down before she tried to leave.
Find her last entry.
? Dalson's Tears, a farmstead in the middle of the Western Plaguelands.
= Mrs. Dalson's diary: 'I don't know what's going to happen now that Harold's turned.'
+ She hid the key on herself. The outhouse held; when it is opened, what was Farmer Dalson is beyond saving.

## western-plaguelands-felstone
Upstairs in a farmhouse west of the tears, a woman who is no longer living
cowers in a corner, begging for a parcel to be delivered
before she is trapped. It has waited in the barn for years.
Find her.
? Felstone Field, in the west of the Western Plaguelands.
= The ghost of Janice Felstone. The parcel is addressed to a Felstone in the city, dated well over four years ago.
+ Better late than never: the Felstone it was meant for is still to be found, alive or not, by the city's census.

## western-plaguelands-renfray
On the shore of an island castle full of ghosts reliving their last happy day,
one ghost remembers everything:
the painter of a family portrait by the beach, a father, a mother and a son,
a painting the father would give anything to see again. Find her.
? The shore of Caer Darrow, in Darrowmere Lake.
= Artist Renfray, who painted 'Of Love and Family' for Tirion Fordring.
+ She hid the painting in Stratholme, behind a painting of the twin moons; when Tirion sees it again, he nearly collapses.

## western-plaguelands-chillwind
In the Alliance's camp in the southern hills sits the last lord of a great house,
which sold its castle to the plague's master to keep its fortune.
His brother lives under the Horde's protection,
and each would pay to see the other's head. Find him.
? Chillwind Camp, in the southern hills of the Western Plaguelands.
= Weldon Barov, of the house of Barov.
+ 'A glorious day it is! Finally, the pockmark of house Barov eliminated and my fortune secure!' Weldon, when his brother Alexi is dead.
