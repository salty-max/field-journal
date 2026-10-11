---
zone: 1436   # Westfall
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: westfall-aegwynn
    tier: near
    reading: Aegwynn and the Dragon Hunt
    object: 175738   # dump 56.5, 30.2; Wowhead 56.4, 30.2
    hint_area: { x: 60.1, y: 31.9, r: 8 }
    danger: "Quiet"
    sources: "object 175738's text"
  - id: westfall-furlbrows
    tier: near
    gestures: [PET]
    where: { x: 60.0, y: 19.4, r: 1 }   # Farmer Furlbrow, dump 60.0, 19.4; Wowhead 60.0, 19.4; Old Blanchy beside him
    hint_area: { x: 60.5, y: 22.4, r: 6 }
    danger: "Quiet"
    sources: "quests 64, 151, 184"
  - id: westfall-stalvan-footlocker
    tier: off
    object: 3643   # dump 41.5, 66.7; Wowhead 41.5, 66.8
    hint_area: { x: 41.1, y: 62.7, r: 8 }
    danger: "Guarded (the Defias in Moonbrook)"
    sources: "quests 67, 68 (the letter, item 889), 98"
  - id: westfall-sanders-jug
    tier: hidden
    object: 34   # dump 40.6, 17.0; Wowhead 40.6, 17.1
    hint_area: { x: 41.5, y: 13.1, r: 8 }
    danger: "Quiet"
    sources: "quests 136, 138, 139, 140"
  - id: westfall-sentinel-hill
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Last Guardian
    object: 175740   # dump 52.6, 53.0; Wowhead's page alike
    hint_area: { x: 52.3, y: 57.0, r: 8 }
    danger: "Quiet"
    sources: "object 175740's text"
# quarry: the zone's own, in the hunts' pass
---
## westfall-aegwynn
At a farm north of the hill where the militia stands,
a book on the shelf tells of a fiery girl made Guardian,
who followed demons into the frozen north
and found them hunting dragons.
? The Saldeans' farm, north of Sentinel Hill.
= Aegwynn and the Dragon Hunt, on the Saldeans' shelf. A farmhouse is an odd place to keep the tale of the Guardian who struck down Sargeras's body.
+ She never knew she had done as he planned: his spirit passed into her and hid in her soul for many years.

## westfall-furlbrows
Where the road comes down into the farmland, a farmer and his wife
wait by a broken wagon with an old horse, worn out by their years of work.
Their farm, their deed and his wedding watch were taken in one night.
The horse, at least, has done nothing to deserve her luck.
? The Jansen Stead, where the road from Elwynn comes into Westfall; the old mare deserves some kindness.
= Theodore and Verna Furlbrow, and Poor Old Blanchy. They mean to reclaim their land when Westfall is fit for honest folk again.
+ The Defias leaned on Furlbrow for his deed, meaning to forge their own from it; the watch he left behind was a wedding gift from Verna's father.

## westfall-stalvan-footlocker
In the bandits' town, a schoolhouse was built for the farm children
by a young tutor who wrote of how lovely the fields were at harvest.
He never sent the letter. It waited in his footlocker.
Find the schoolhouse, and the footlocker in it.
? Moonbrook, in Westfall's south, had a schoolhouse.
= Stalvan Mistmantle's footlocker, in the Moonbrook schoolhouse. The letter is cheerful. Duskwood knows how his story ends.
+ Darkshire's Night Watch would come to call his a life of depravity, and count the innocent who died by his hand.

## westfall-sanders-jug
A captain left a trail across the farmland:
a footlocker on the shore, a barrel among the fields,
and a jug that smells of whiskey by the lone windmill on the sea bluffs.
Find the jug; the sea will tell you the rest.
? On Westfall's northern coast, a windmill stands alone on the bluffs.
= Captain Sander's old jug. The rest of the treasure lies out to sea, west, if no one has taken it.
+ The ink of the last clue has run, and the paper smells of whiskey: face west, walk down to the shore, and keep going.

## westfall-sentinel-hill
On the hill where the farmers' militia keeps watch,
a book takes up where the farm's left off:
the Guardian, grown old, chose her own heir,
and never knew what had hidden in him before he was born.
? Sentinel Hill.
= The Last Guardian. Aegwynn's son was Medivh, 'keeper of secrets' in the high elven tongue.
+ He grew up at Azeroth's court with two friends, Llane and Anduin Lothar, and the three boys made mischief all over the kingdom.
