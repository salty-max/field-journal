---
zone: 1438   # Teldrassil
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: teldrassil-shadowglen-moonwell
    tier: near
    gestures: [DRINK, THIRSTY]
    object: 19549   # Shadowglen Moonwell: Classic world spawn and Questie 59.95, 33.05
    position_check: questie   # spell-focus object: Wowhead has no map points
    hint_area: { x: 60.0, y: 33.0, r: 3 }
    danger: "Quiet"
    quest_overlap: [921]
    quest_context: "Crown of the Earth asks for a phial of water. Yonder asks for a drinking gesture at the well, with no quest or item required."
    sources: "Crown of the Earth (921), Tenaron's account of moonwells; Mooncloth (18560), its moonwell requirement; Classic database and Questie agree on the pool, matching the user's 59.9, 33.1"
  - id: teldrassil-maneweavers
    tier: near
    gestures: [THANK, BOW, HELLO, GREET, WAVE, SMILE]
    creature: 3605   # Nadyia Maneweaver, 41.9, 49.4
    hint_area: { x: 42.0, y: 49.5, r: 4 }
    danger: "Quiet (owls in the trees)"
    quest_overlap: [97946]
    quest_context: "Forever's Camping 101: Leatherworking ends at Nadyia. Returning her hospitality is separate from the profession quest and needs no training."
    sources: "Nadyia's Classic gossip, reported firsthand at https://www.wowhead.com/classic/npc=3605#comments and reproduced at https://warcraft.wiki.gg/wiki/Nadyia_Maneweaver; Classic database spawn and frozen Wowhead points"
quarry:
  id: 14430   # Duskstalker
  sources: "the WoWWiki archive's Duskstalker page (the south shore, the two coves, Tendon Rip); the dump's spawn; Wowhead's sightings"
---
## teldrassil-shadowglen-moonwell
North of the tree where young elves begin,
the moon has a pool of its own.
Leave the errands and empty vials aside.
A dry throat has a use for this water, too.
? North of Aldrassil, at the moonwell. A drinking gesture is enough. No vial or drink item is needed.
= The Shadowglen Moonwell. Tenaron Stormgrip says the moonwells hold water from the Well of Eternity, and that the Sentinels revere them as shrines to Elune.
+ Tailors bring felcloth to moonwells to purify it into mooncloth. A pool that serves as a shrine also has work to do.

## teldrassil-maneweavers
West of the furbolgs' hollow,
a house stands apart from the road to the city.
Its leatherworker says she has little to offer, yet welcomes you into her home.
Return the kindness.
? West of Ban'ethil Hollow, at the house. Thank Nadyia for her welcome.
= Nadyia Maneweaver, who teaches leatherworking beside Radnaal, the skinning trainer. She offers what hospitality their home can provide, however little she says they have.
+ Her advice to students is practical: smaller stitches keep things in their quivers and ammunition pouches. They also make a less lumpy tunic.

## quarry
South of the great lake, along the shore where the owls hunt,
a cat of the dusk hunts too, and goes where it likes.
It strikes at the legs first, to slow what it chases.
Be the one who does the chasing.
= Duskstalker, a cat hunting the shore of Lake Al'Ameth.
+ It keeps to the south shore of Lake Al'Ameth, now near one of the shore's two southward coves, now near the other.
