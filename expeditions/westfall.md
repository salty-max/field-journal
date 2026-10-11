---
zone: 1436   # Westfall
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: westfall-near
    tier: near
    reading: Aegwynn and the Dragon Hunt
    object: 175738   # dump 56.5, 30.2; Wowhead 56.4, 30.2
    hint_area: { x: 55.3, y: 34.0, r: 8 }
    danger: "Quiet"
    sources: "object 175738's text"
  - id: westfall-off
    tier: off
    object: 3643   # dump 41.5, 66.7; Wowhead 41.5, 66.8
    hint_area: { x: 45.4, y: 67.7, r: 8 }
    danger: "Guarded (the Defias in Moonbrook)"
    sources: "quests 67, 68 (the letter, item 889), 98"
  - id: westfall-hidden
    tier: hidden
    object: 34   # dump 40.6, 17.0; Wowhead 40.6, 17.1
    hint_area: { x: 43.9, y: 19.2, r: 8 }
    danger: "Quiet"
    sources: "quests 136, 138, 139, 140"
# quarry: the zone's own, in the hunts' pass
---
## westfall-near
At a farm north of the hill where the militia stands,
a book on the shelf tells of a fiery girl made Guardian,
who followed demons into the frozen north
and found them hunting dragons. Read it where the farmers keep it.
? The Saldeans' farm, north of Sentinel Hill.
= Aegwynn and the Dragon Hunt, on the Saldeans' shelf. A farmhouse is an odd place to keep the tale of the Guardian who struck down Sargeras's body.
+ She never knew she had done as he planned: his spirit passed into her and hid in her soul for many years.

## westfall-off
In the bandits' town, a schoolhouse was built for the farm children
by a young tutor who wrote of how lovely the fields were at harvest.
He never sent the letter. It waited in his footlocker.
Find the schoolhouse, and the footlocker in it.
? Moonbrook, in Westfall's south, had a schoolhouse.
= Stalvan Mistmantle's footlocker, in the Moonbrook schoolhouse. The letter is cheerful. Duskwood knows how his story ends.
+ Darkshire's Night Watch would come to call his a life of depravity, and count the innocent who died by his hand.

## westfall-hidden
A captain left a trail across the farmland:
a footlocker on the shore, a barrel among the fields,
and a jug that smells of whiskey by the lone windmill on the sea bluffs.
Find the jug; the sea will tell you the rest.
? On Westfall's northern coast, a windmill stands alone on the bluffs.
= Captain Sander's old jug. The rest of his treasure lies out to sea, west, if no one has taken it.
+ The ink of his last clue has run, and the paper smells of whiskey: face west, walk down to the shore, and keep going.
