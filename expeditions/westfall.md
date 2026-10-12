---
zone: 1436   # Westfall
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: westfall-aegwynn
    tier: near
    reading: Aegwynn and the Dragon Hunt
    object: 175738   # dump 56.5, 30.2; Wowhead 56.4, 30.2
    hint_area: { x: 60.1, y: 31.9, r: 8 }
    danger: "Quiet"
    sources: "object 175738's text"
  - id: westfall-dead-acre
    tier: off
    gestures: [MOURN, SIGH]
    area: The Dead Acre   # placed: the client's overlay: 62.4, 61.4
    hint_area: { x: 60.0, y: 58.5, r: 6 }
    danger: "Guarded (harvest reapers to level 18; the Foe Reaper 4000, at times)"
    sources: "the WoWWiki archive's The Dead Acre and Foe Reaper 4000 pages"
  - id: westfall-coffin-tree
    tier: hidden
    night: true
    creature: 572   # Leprithus, who rises only at night (event 27): dump 41.7, 29.3, at the tree, with two ghouls
    hint_area: { x: 42.5, y: 31.0, r: 4 }
    danger: "Quiet by day; perilous after dark (Leprithus, level 19, and two ghouls)"
    sources: "the dump's spawns and its night event; the WoWWiki archive's Leprithus page (the fenced coffins, the second tree, two at once)"
  - id: westfall-sentinel-hill
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: The Last Guardian
    object: 175740   # dump 52.6, 53.0; Wowhead's page alike
    hint_area: { x: 52.3, y: 57.0, r: 8 }
    danger: "Quiet"
    sources: "object 175740's text"
quarry:
  id: 462   # Vultros
  sources: "the WoWWiki archive's Vultros page (its fields, its swoop); the dump's spawns (one at a time, 21 hours to return)"
---
## westfall-aegwynn
At a farm north of the hill where the militia stands,
a book on the shelf tells of a fiery girl made Guardian,
who followed demons into the frozen north
and found them hunting dragons.
? The Saldeans' farm, north of Sentinel Hill.
= Aegwynn and the Dragon Hunt, on the Saldeans' shelf. A farmhouse is an odd place to keep the tale of the Guardian who struck down Sargeras's body.
+ She never knew she had done as he planned: his spirit passed into her and hid in her soul for many years.

## westfall-dead-acre
In the south-east, near the bridge into the dark wood,
a farm burned when the Brotherhood came, fields and all,
and its ruins still smoke. The iron harvesters that walk its rows
are the strongest left in the west. Grieve for the farm, and keep moving.
? South-east Westfall, by the bridge to Duskwood: a farm that is only ashes.
= The Dead Acre: one of Westfall's many farms, burned by the Defias as they took the land.
+ The Foe Reaper 4000, a harvest golem worse than all the rest, walks these fields at times, and others of Westfall's.

## westfall-coffin-tree
South-west of the old mine stands a lone tree,
and under it a little fence keeps a plot of coffins.
By day there is nothing there but the wood and the wind.
Come back after dark, and do not come alone.
? A lone tree south-west of the Jangolode Mine, its coffins fenced; after dark.
= Leprithus, a ghoul that rises only at night, with two of its kind, at the coffin tree by the Jangolode Mine.
+ On the same nights, another of it rises at a second coffin tree in the Dagger Hills, and walks from there to the bridge into Duskwood.

## westfall-sentinel-hill
On the hill where the farmers' militia keeps watch,
a book takes up where the farm's left off:
the Guardian, grown old, chose her own heir,
and never knew what had hidden in him before he was born.
? Sentinel Hill.
= The Last Guardian. Aegwynn's son was Medivh, 'keeper of secrets' in the high elven tongue.
+ He grew up at Azeroth's court with two friends, Llane and Anduin Lothar, and the three boys made mischief all over the kingdom.

## quarry
A carrion bird far too big for these fields comes down on one of them at a time,
anywhere from the pumpkin farm in the north to the dust plains in the south.
Its swoop leaves you reeling. When it falls, a whole day passes before another field has it.
= Vultros, a carrion bird of level 26, far above anything else in Westfall, in one of its fields: the Dead Acre, the Dust Plains, Furlbrow's pumpkins, Stendel's Pond, or the fields by Sentinel Hill.
+ Twenty-one hours at the least before it comes back, and never two of it at once.
