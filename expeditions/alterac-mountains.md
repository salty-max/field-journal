---
zone: 1416   # Alterac Mountains
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: alterac-mountains-ansirem
    tier: near
    where: { x: 18.8, y: 78.5, r: 1 }   # Archmage Ansirem Runeweaver, dump 18.8, 78.5; Wowhead 18.8, 78.4
    hint_area: { x: 20.4, y: 76.0, r: 6 }
    danger: "Quiet"
    sources: "quests 602, 603"
  - id: alterac-mountains-goldir
    tier: off
    where: { x: 60.0, y: 43.7, r: 1 }   # Gol'dir, dump 60.0, 43.7; Wowhead 60.0, 43.8
    hint_area: { x: 63.0, y: 43.5, r: 6 }
    danger: "Perilous (the Syndicate)"
    sources: "quests 503, 506"
  - id: alterac-mountains-elysa
    tier: off
    where: { x: 39.3, y: 14.3, r: 1 }   # Elysa, dump 39.3, 14.3; Wowhead 39.2, 14.4
    hint_area: { x: 36.3, y: 14.1, r: 6 }
    danger: "Guarded (the Syndicate)"
    sources: "quests 506, 507, 508"
  - id: alterac-mountains-ravenholdt
    tier: hidden
    gestures: [SNEAK]
    area: Ravenholdt Manor   # placed: Lord Jorach Ravenholdt (creature 6768), dump 86.0, 78.9; Wowhead 86.0, 79.0
    hint_area: { x: 82.8, y: 77.5, r: 7 }
    danger: "Quiet"
    sources: "quests 6681, 8233"
# quarry: the zone's own, in the hunts' pass
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
