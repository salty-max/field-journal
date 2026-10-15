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
    gestures: [MOURN, SIGH, CRY]
    area: The Dead Acre   # placed: the client's overlay: 62.4, 61.4
    hint_area: { x: 60.0, y: 58.5, r: 6 }
    danger: "Guarded (harvest reapers to level 18, and at times the Foe Reaper 4000)"
    sources: "the WoWWiki archive's The Dead Acre and Foe Reaper 4000 pages"
quarry:
  id: 462   # Vultros
  sources: "the WoWWiki archive's Vultros page (its fields, its swoop); the dump's spawns (one at a time)"
---
## westfall-aegwynn
On a farmhouse shelf north of the militia's hill,
seek a young woman's victory over a fallen god.
She believed she had ended the danger. The page remembers what followed her home.
? The Saldeans' farm, north of Sentinel Hill. Open the book on the farmhouse shelf.
= Aegwynn and the Dragon Hunt, on the Saldeans' shelf. A farmhouse is an odd place to keep the tale of the Guardian who struck down Sargeras's body.
+ She never knew she had done as he planned: his spirit passed into her and hid in her soul for many years.

## westfall-dead-acre
In the south-east, near the bridge into the dark wood,
a farm burned when the Brotherhood came, fields and all,
and its ruins still smoke. The iron harvesters that walk its rows
are the strongest left in the west. Grieve for the farm, and keep moving.
? South-east Westfall, by the bridge to Duskwood: a farm that is only ashes. A sorrowful sigh belongs here.
= The Dead Acre: one of Westfall's many farms, burned by the Defias as they took the land.
+ The Foe Reaper 4000, a harvest golem worse than all the rest, walks these fields at times, and others of Westfall's.

## quarry
A carrion bird far too big for these fields comes down on one of them at a time,
anywhere from the pumpkin farm in the north to the dust plains in the south.
Its swoop leaves you reeling.
= Vultros, a carrion bird of level 26, far stronger than Westfall's ordinary scavengers.
+ It has been seen by Stendel's Pond, Sentinel Hill and the Dead Acre too, as well as in the northern farms and the southern dust.
