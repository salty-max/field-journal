---
zone: 1426   # Dun Morogh
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: dun-morogh-etched-note
    tier: near
    reading: Etched Note
    object: 174746   # dump 52.5, 37.1; Wowhead 52.6, 37.1
    hint_area: { x: 49.8, y: 34.1, r: 8 }
    danger: "Quiet"
    sources: "object 174746's text; quests 1650, 1652, 1653, 1806"
  - id: dun-morogh-tog
    tier: near
    creature: 6119   # Tog Rustsprocket, dump 47.3, 53.8, in Kharanos
    found: target   # in the town: only by speaking to him
    hint_area: { x: 49.0, y: 56.0, r: 4 }
    danger: "Quiet"
    sources: "Tog Rustsprocket's own words (his gossip); the WoWWiki archive's Tog Rustsprocket page"
  - id: dun-morogh-misty-pine
    tier: off
    area: Misty Pine Refuge   # placed: the client's overlay: 57.4, 42.7
    hint_area: { x: 55.5, y: 45.0, r: 6 }
    danger: "Quiet"
    sources: "the WoWWiki archive's Misty Pine Refuge and Father Gavin pages; the dump (Father Gavin alone)"
  - id: dun-morogh-ironband
    tier: off
    area: Ironband's Compound   # placed: no overlay of its own (it shares Helm's Bed Lake's)
    anchor: { creature: 6124 }   # what places its hint: Captain Beld, who holds it
    hint_area: { x: 75.5, y: 60.0, r: 6 }
    danger: "Guarded (Dark Iron spies to level 10; Captain Beld, 11)"
    sources: "the WoWWiki archive's Ironband's Compound and Helm's Bed Lake pages (the abandoned building, the hole in the ice); the dump's spawns"
  - id: dun-morogh-gibblewilt
    tier: hidden
    creature: 8503   # Gibblewilt, two spawns outside Gnomeregan, dump 24.2, 43.6 and 26.4, 36.4
    hint_area: { x: 23.0, y: 40.0, r: 6 }
    danger: "Guarded (leper gnomes to level 10; Gibblewilt, 11)"
    sources: "the WoWWiki archive's Gibblewilt and Leper gnome pages (Gnomeregan's fall); the dump's spawns"
quarry:
  id: 1132   # Timber
  sources: "the WoWWiki archive's Timber page (the island, his two wolves, the respawn, his drops, the pet); the dump's spawns"
---
## dun-morogh-etched-note
Below the great gates, where every traveller climbs,
a smith has claimed an anvil in writing,
politely, and very firmly.
Find what he etched beside it.
? At the foot of the road up to Ironforge, an anvil has an owner, and says so.
= 'This anvil is the property of Jordan Stilwell - Please do NOT use!' Ironforge has a great many anvils. This one is spoken for.
+ Jordan Stilwell is no dwarf: a human smith with a house on Westfall's Longshore, who meant to be a paladin before smithing took him, and came to work beside the dwarves while his wife, Daphne, waited by the sea. The paladins who pass his tests carry a hammer he forges and names for a dwarven paladin he called a friend.

## dun-morogh-tog
In the brewers' town in the heart of the snows,
a gnome who cannot abide them stands and grumbles:
the snow soaks his robe and spoils everything he owns.
Find him, and let him tell you about it.
? Kharanos: among its people, a gnome in a wet robe.
= Tog Rustsprocket, of Kharanos: 'I wish the snow would just all melt away. It's always getting my robe wet and messing up everything!'
+ He keeps a message for the warlocks who come his way, and sends them on to Lago Blackwrench.

## dun-morogh-misty-pine
In the pines east of the road that climbs to the great gates,
a refuge stands that belongs to the Dawn.
One priest keeps it, alone, studying the plague
while the rest of his order fights it in the north.
? North-east of Kharanos, east of the road up to the Gates of Ironforge: a refuge in the pines.
= Misty Pine Refuge, an outpost of the Argent Dawn, kept by Father Gavin alone.
+ The rest of the Dawn fights the Scourge in the Plaguelands; Gavin keeps the refuge, and studies the plague of undeath from as far away as it gets.

## dun-morogh-ironband
By a frozen lake whose ice is kept open in one place,
so that there is always fresh water,
an abandoned house south of the shore has new tenants:
dwarves of the dark iron, who do not care for visitors.
? South of Helm's Bed Lake, in eastern Dun Morogh: the house the Dark Irons have taken.
= Ironband's Compound, a base of the Dark Iron dwarves in Dun Morogh, under their Captain Beld.
+ Their spies watch the lake from the slopes around it; Ironforge would very much like to know what the Dark Irons are doing so close to its gates.

## dun-morogh-gibblewilt
Outside the gnomes' fallen city, by the small buildings near its door,
one of its own still makes his rounds,
though the poison changed him with all the rest.
He has kept his name, which most of the changed have lost. He is not always there.
? Outside Gnomeregan, near its entrance: among the leper gnomes, one with a name.
= Gibblewilt, a leper gnome, one of the few with a name. Like the rest, he takes anyone who comes near for a trogg.
+ When troggs from the Uldaman dig overran Gnomeregan, High Tinker Mekkatorque flooded the city with radiation to drive them out. It killed more gnomes than troggs, and twisted many of those it did not kill.

## quarry
On the island in the middle of the frozen lake to the north-west,
a white wolf leads the pack, with two starving wolves at his heels.
Bring him into a fight and he will bring others.
Thin the island first.
= Timber, a white wolf, and very likely the alpha of Iceflow Lake's pack. He alone carries the Silver-lined Bracers and the White Wolf Gloves.
+ A hunter can tame him: a good first companion for anyone fond of wolves. He comes back within the hour.
