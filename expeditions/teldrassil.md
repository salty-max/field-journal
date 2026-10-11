---
zone: 1438   # Teldrassil
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: teldrassil-maneweavers
    tier: near
    gestures: [THANK, BOW]
    creature: 3605   # Nadyia Maneweaver, dump 41.9, 49.4 (Radnaal beside her, 42.1, 50.0)
    hint_area: { x: 44.0, y: 47.5, r: 5 }
    danger: "Quiet (owls in the trees)"
    sources: "Nadyia Maneweaver's own words (her gossip); the dump (the house, Radnaal, no quest)"
quarry:
  id: 14430   # Duskstalker
  sources: "the WoWWiki archive's Duskstalker page (the south shore, the two coves, Tendon Rip, the respawn); the dump's spawn; Wowhead's sightings"
---
## teldrassil-maneweavers
On the road west to the city, a house stands by itself,
and the two who keep it work leather and skins.
They have little to offer, she will tell you,
and offers it all the same. Accept the welcome.
? On the road from Dolanaar to Darnassus, west of Ban'ethil Hollow: a house, and two who teach a craft in it.
= Nadyia and Radnaal Maneweaver, who teach leatherworking and skinning from their own house: 'Welcome to our home. Radnaal and I have little to offer, but you are welcome to what hospitality we can provide.'
+ Nadyia has advice for her students: smaller stitches, so that fewer arrows slip out of the quivers; besides, no one likes a lumpy tunic.

## quarry
South of the great lake, along the shore where the owls hunt,
a cat of the dusk hunts too, and goes where it likes.
It strikes at the legs first, to slow what it chases.
Be the one who does the chasing.
= Duskstalker, a cat of Teldrassil, seldom seen: it comes back an hour or two after it falls.
+ It keeps to the south shore of Lake Al'Ameth, now near one of the shore's two southward coves, now near the other.
