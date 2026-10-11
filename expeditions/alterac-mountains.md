---
zone: 1416   # Alterac Mountains
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: alterac-mountains-ansirem
    tier: near
    creature: 2543   # Archmage Ansirem Runeweaver, dump 18.8, 78.5; Wowhead 18.8, 78.4
    hint_area: { x: 20.4, y: 76.0, r: 6 }
    danger: "Quiet"
    sources: "quests 602, 603"
  - id: alterac-mountains-goldir
    tier: off
    creature: 2316   # Gol'dir, dump 60.0, 43.7; Wowhead 60.0, 43.8
    hint_area: { x: 63.0, y: 43.5, r: 6 }
    danger: "Perilous (the Syndicate)"
    sources: "quests 503, 506"
  - id: alterac-mountains-elysa
    tier: off
    creature: 2317   # Elysa, dump 39.3, 14.3; Wowhead 39.2, 14.4
    hint_area: { x: 36.3, y: 14.1, r: 6 }
    danger: "Guarded (the Syndicate)"
    sources: "quests 506, 507, 508"
  - id: alterac-mountains-ravenholdt
    tier: hidden
    gestures: [SNEAK]
    area: Ravenholdt Manor   # placed: Lord Jorach Ravenholdt (creature 6768), dump 86.0, 78.9; Wowhead 86.0, 79.0
    anchor: { creature: 6768 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 82.8, y: 77.5, r: 7 }
    danger: "Quiet"
    sources: "quests 6681, 8233"
quarry:
  id: 2306
  sources: "quests 523 (Magistrate Maleb), 566 (Tarren Mill's poster)"
---
## alterac-mountains-ansirem
By the great lake's northern shore, the city of the mages lies broken,
and its wizards work to raise it again.
One of them waits outside, and can never resist a magical puzzle.
Find him.
? Dalaran, on the shore of Lordamere Lake, in Alterac's south-west.
= Archmage Ansirem Runeweaver, outside the ruins of Dalaran.
+ He once wrote a tome on the legends of the Gurubashi Empire, and gave a troll dagger from his research to his willful daughter Catelyn, who ran off to Booty Bay to be a pirate.

## alterac-mountains-goldir
In a mountain town the Syndicate holds, an orc from across the sea
hauls burdens and digs for his captors:
he led the Warchief's expedition here, and it went awry.
Find him.
? Strahnbrad, in Alterac's north-east.
= Gol'dir, a prisoner of the Syndicate in Strahnbrad.
+ Lord Aliden Perenolde came to see him, and spoke of taking the orcs who stood against him as slaves, just as his father and his mentor, the despised Blackmoore, had planned.

## alterac-mountains-elysa
In a manor on the lake shore, a lord of thieves kept a girl,
and around her neck hung a pendant that once belonged to another girl,
one who helped a young slave escape a keep.
Find her.
? Dandred's Fold, the Perenolde manor on Lordamere Lake, in Alterac's north.
= Elysa, Aliden Perenolde's mistress. Taretha Foxton's pendant hung around her neck.
+ 'No, no please don't hurt me! I never meant your people any harm, he's had me against my will!' She gives the pendant up gladly: 'I want no memory of him.'

## alterac-mountains-ravenholdt
In the hills above the foothills, a manor hides from all who do not know the way,
a hall for those who work unseen,
and its master welcomes only the cunning.
Find it, and arrive as its guests do.
? A path in the mountains north-west of Durnholde Keep; nobody arrives there in plain sight.
= Ravenholdt Manor, hall of the Assassin's League. Lord Jorach Ravenholdt is its master.
+ 'Your first task is to find the manor, hidden away in the hills of Hillsbrad and demonstrate your cunning.' The letter Fahrad sends young thieves.

## quarry
A noble of the fallen kingdom, known for a cold heart
and brutal practices, put his name to a Syndicate contract.
Southshore wants him brought to justice; Tarren Mill wants him dead.
He was last seen in the uplands, north of the ruins of Strahnbrad.
= Baron Vardus, a high-ranking member of the Syndicate. Magistrate Maleb in Southshore and High Executor Darthalia in Tarren Mill each pay for his head.
+ Maleb was not surprised to find the Baron behind it; Darthalia counts one Syndicate leader fewer.
