---
zone: 1431   # Duskwood
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
# None of them is a place a quest sends you.
riddles:
  - id: duskwood-twilight-grove
    tier: near
    gestures: [SLEEP, LAYDOWN]
    area: Twilight Grove   # placed: the client's overlay: 47.7, 40.4, half-size 10.7 by 18.7
    hint_area: { x: 46.0, y: 43.0, r: 14 }
    danger: "Quiet, but perilous when a dragon of the Nightmare is there"
    sources: "the WoWWiki archive's Duskwood page (the crater, the twilight of its own); the Codex's dragons-of-nightmare page"
  - id: duskwood-callahan
    tier: off
    faction: alliance   # its keeper attacks the other side: this side's alone
    gestures: [SALUTE, BOW]
    creature: 2142   # Watcher Callahan, dump 81.9, 19.7, alone
    hint_area: { x: 79.0, y: 21.5, r: 6 }
    danger: "Quiet"
    sources: "the dump's spawn (no quest); the WoWWiki archive's Kzixx, Darkened Bank, Darkshire and Duskwood pages (the goblin by the road, the bridge, the Night Watch, the army at the front)"
  - id: duskwood-unseen
    tier: hidden
    gestures: [PEER, LOOK, GAZE, STARE, SHIVER]
    name: The Unseen
    creature: 3094   # the Unseen: two, still, on two floors of one house, dump 19.2, 53.4 and 53.8; Wowhead's
    hint_area: { x: 20.0, y: 52.0, r: 2 }
    danger: "Perilous (invisible undead, levels 49 to 51)"
    sources: "https://www.wowhead.com/classic/npc=3094/unseen (Detect Invisibility; conflicting reports of Horde hostility); https://www.wowhead.com/classic/spell=2970/detect-invisibility; the dump's and Wowhead's spawns of creature 3094 in Raven Hill"
  - id: duskwood-darkshire
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 11040   # Watcher Brownell, dump 74.6, 45.4
    found: target   # in the town square: only by speaking to her
    hint_area: { x: 75.5, y: 47.0, r: 4 }
    danger: "Quiet"
    sources: "Watcher Brownell's own words (her gossip); the WoWWiki archive's Watcher Backus page; Grand Hamlet: Warcraft: Orcs & Humans, Warcraft Legends 2"
quarry:
  id: 771   # Commander Felstrom
  sources: "the WoWWiki archive's Commander Felstrom and Lord Malathrom pages (Felstrom Resurrection, Sloth and Sludge); the dump's spawns"
---
## duskwood-twilight-grove
In the heart of the dark wood a great tree stands apart:
a door the dreaming druids walk through to the Emerald Dream.
Green dragons were set to keep it. The Nightmare took the keepers.
The druids begin that journey with their eyes closed. Follow their example.
? The road through the forest bends around something older than the town. Sleep beneath the great tree, as the druids do. The door itself stays shut.
= The Twilight Grove, in the crater of a volcano long dead. Its tree is one of four doors the green dragonflight keeps into the Emerald Dream, and its keepers came back from the Dream changed.
+ The dusk here is not Duskwood's darkness: the sleeping druids keep a twilight of their own over the crater, quite unlike the rest of the forest.

## duskwood-callahan
Where the northern bank ends, by the road into the red mountains,
the Night Watch keeps one post far from its walls.
Its only company is a goblin with rare goods to sell.
Honour the post, whoever keeps it.
? The road from Darkshire to Redridge, where it leaves the forest: a watcher, and a goblin's stall. Give the watcher a soldier's salute.
= Watcher Callahan, the Night Watch's farthest post on the road to Redridge. The Watch is Darkshire's own militia, under the mayor's daughter, Commander Althea Ebonlocke.
+ Stormwind's army is away at the front, and has all but abandoned the forest: the Watch is all that keeps its roads open.

## duskwood-unseen
The village on the hill of ravens was left to its dead,
and most of its houses stand empty, or seem to.
In one of them, a household keeps both floors, hidden from an unaided eye.
Study the empty rooms, and leave their occupants undisturbed.
? Raven Hill, at the village's northern edge: a house of two floors, and no one in it. Inside, peer into the empty rooms.
= The Unseen: invisible wraiths, of a strength far beyond Duskwood's. Two keep this house. Others keep the rest of Raven Hill's.
+ A warlock's Detect Invisibility reveals them. Their invisibility is not a rogue's stealth: an eye trained to find the latter may miss an entire household here.

## duskwood-darkshire
In the town that was Grand Hamlet before the dark came, the Night Watch walks the streets.
One young watcher has eyes for another, the bravest of them all, she says,
and wonders whether he has ever noticed her.
Find her among them: she will tell you herself.
? Darkshire's square: speak to the watchers there, one by one.
= Watcher Brownell. The one she admires is Watcher Backus, who keeps the road west of Manor Mistmantle.
+ Darkshire was Grand Hamlet once, a quaint woodland village. The name changed as the darkness came over the forest.

## quarry
Beneath the cemetery on the hill of ravens, a dead commander keeps his post.
Strike him down and he stands again, whole, while you watch:
the spell is his own, and he casts it as he falls.
Finish him before he finishes it.
= Commander Felstrom, of the Dawning Wood Catacombs under Raven Hill Cemetery. Lord Malathrom, a ghoul who calls up two foul servants, Sloth and Sludge, keeps the same dark.
+ Each copy that rises fights as long as the last. Fail to stop the spell, and the hunt has no end.
