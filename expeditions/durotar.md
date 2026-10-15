---
zone: 1411   # Durotar
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: durotar-rokar
    tier: near
    gestures: [BOW, SALUTE]
    creature: 6586   # Rokar Bladeshadow, dump 55.5, 34.0 (Harroc beside him)
    hint_area: { x: 57.5, y: 36.5, r: 5 }
    danger: "Quiet (boars and raptors about)"
    sources: "Rokar Bladeshadow's own words (his gossip); the WoWWiki archive's Rokar Bladeshadow and Harroc pages; the dump (no quest)"
  - id: durotar-tiragarde
    tier: off
    reading: Rise of the Horde
    object: 175742   # dump 59.6, 58.1; Wowhead 59.6, 58.2
    hint_area: { x: 61.2, y: 54.4, r: 8 }
    danger: "Guarded (Kul Tiran soldiers)"
    sources: "object 175742's text; Warcraft III: Reign of Chaos (Durotar named for Durotan); the dump (the keep's Kul Tirans)"
quarry:
  id: 5824   # Captain Flat Tusk
  sources: "the WoWWiki archive's Captain Flat Tusk and Geolord Mottle pages; the dump's spawns"
---
## durotar-rokar
North-east of the town on the red hill, just off the road,
an old orc keeps a house and a patch of crops, with a young hand to help.
His name was not made by farming.
Pay him the respect his years have earned.
? North-east of Razor Hill, east of Razorwind Canyon: a farmhouse, an old orc, and his farmhand in the garden. Target the old orc and bow or salute respectfully.
= Rokar Bladeshadow, an aged orc farmer, and Harroc, his farmhand: 'What's a young one like you out visiting an old farmer like me?'
+ Harroc works the garden outside. Rokar keeps to the house, and to whatever he was before he was a farmer.

## durotar-tiragarde
In the retaken keep on the red coast, find the chieftains gathered to drink from one cup.
One chieftain in the account will not join them.
His son's new land lies outside these walls.
? South of Razor Hill, Kul Tiras still holds a keep on Durotar's shore. Open the book about the Horde's beginning, not the drinking cup.
= Rise of the Horde, at Tiragarde Keep. The book credits Durotan with refusing Mannoroth's blood. The land outside bears his name.
+ The keep was raised by Admiral Proudmoore's men, who crossed the sea to destroy the Horde in its new land. It is theirs still.

## quarry
West of the road, the Razormane quilboar have taken grounds of their own,
and raid the farms and camps nearby under two leaders.
The captain among them is the first true danger many young orcs and trolls meet,
and most of them underestimate him only once.
= Captain Flat Tusk, of the Razormane: an elite, which the young of Durotar learn to respect the hard way.
+ Geolord Mottle, a quilboar shaman with a healing wave and a lightning shield, keeps the same huts.
