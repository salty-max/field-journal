---
zone: 1426   # Dun Morogh
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: dun-morogh-empty-camp
    tier: off
    name: The abandoned camp
    landmark: dun-morogh-abandoned-camp
    radius: 15
    hint_area: { x: 39.0, y: 67.5, r: 1.5 }
    danger: "Guarded (a young black bear)"
    sources: "Owner's in-game coordinate correction on 17 October 2026: 39.2, 67.6. Reviewed wow-data landmark dun-morogh-abandoned-camp. The earlier bear-spawn association was wrong. No live bear or target is required. The cause of the abandonment is unknown."
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
  - id: dun-morogh-range
    tier: near
    gestures: [COVEREARS, DUCK, COWER, CRINGE]
    name: Rumbleshot's Range
    creature: 10805   # Spotter Klemmy, dump 40.7, 64.9, at the camp: the riflemen and the mortar team beside him
    found: place   # the noise is the subject, not a dwarf's ears
    radius: 75   # original firing-range coverage, including Klemmy at 40.8, 66.6
    hint_area: { x: 41.0, y: 64.0, r: 4 }
    danger: "Quiet"
    sources: "the dump's script of the camp (dbscripts_on_creature_movement 1061001 to 1061004: the five head out to the range; broadcast texts 6106 to 6142: the riflemen's contest; the three Mortar Team Target Dummies); warcraft.wiki.gg's Hegnar Rumbleshot, Shorty, Spotter Klemmy, Rifleman Wheeler and Rifleman Middlecamp pages"
  - id: dun-morogh-fluffy
    tier: off
    gestures: [SOOTHE, CALM, PET, COMFORT]
    creature: 1352   # Fluffy, a rabbit: dump 63.0, 50.8, on a path round the ram pen
    found: target   # it never stops running
    hint_area: { x: 63.0, y: 50.5, r: 3 }
    danger: "Quiet"
    sources: "the dump: Fluffy's path, and Yarlyn Amberstill's words as she runs after it (broadcast texts 159 to 165, in Dwarvish); warcraft.wiki.gg's Fluffy and Yarlyn Amberstill pages (a dwarf girl, chasing her pet rabbit)"
quarry:
  id: 1132   # Timber
  sources: "the WoWWiki archive's Timber page (the island, his two wolves, his drops, the pet); the dump's spawns"
---
## dun-morogh-empty-camp
Southwest of the gunsmith's noisy company,
another camp has no one to answer.
A young black bear wanders close to where they stayed.
Find the place the campers left behind.
? Just southwest of Rumbleshot's range, look for the abandoned camp near a young black bear. Walk into the camp. The bear need not be there.
= An abandoned camp a short walk from Rumbleshot's range. A young black bear wanders nearby, but why the campers left is unknown.
+ Perhaps the bear found the camp empty. Perhaps the campers found the bear first. The League has no witness to ask, and the bear is unlikely to settle it.

## dun-morogh-etched-note
Below the great gates, where every traveller climbs,
a smith has claimed an anvil in writing,
politely, and very firmly.
Find what he etched beside it.
? At the foot of the road up to Ironforge, an anvil has an owner, and says so. Open the writing beside the anvil and read it.
= 'This anvil is the property of Jordan Stilwell - Please do NOT use!' Ironforge has a great many anvils. This one is spoken for.
+ Jordan Stilwell is no dwarf: a human smith with a house on Westfall's Longshore, who meant to be a paladin before smithing took him, and came to work beside the dwarves while his wife, Daphne, waited by the sea. The paladins who pass his tests carry a hammer he forges and names for a dwarven paladin he called a friend.

## dun-morogh-tog
In the brewers' town in the heart of the snows,
a gnome who cannot abide them stands and grumbles:
the snow soaks his robe and spoils everything he owns.
Find him, and let him tell you about it.
? Kharanos: among its people, a gnome in a wet robe. Speak to the complaining gnome.
= Tog Rustsprocket, of Kharanos: 'I wish the snow would just all melt away. It's always getting my robe wet and messing up everything!'
+ He keeps a message for the warlocks who come his way, and sends them on to Lago Blackwrench.

## dun-morogh-range
On the road out of the valley where young dwarves begin,
a gunsmith keeps a camp, and beside it a range.
Two riflemen quarrel, and the mortar has the last word.
Ten fingers make poor earplugs, but they're all you've brought.
? Hegnar Rumbleshot's camp, by the road from Coldridge Pass to Kharanos. Cover your ears at the firing range with /coverears.
= Rumbleshot's practice range. Every so often the five dwarves of the camp head out to it. First come Riflemen Middlecamp and Wheeler, who shoot at an orc target and a row of bottles. Then the mortar team, Angus and Shorty, fire at three target dummies in turn, while Spotter Klemmy runs back and forth.
+ Middlecamp misses the orc target twice and the bottles twice, while Wheeler hits the target without trying, and the middle target dead centre. Then Wheeler only hits the side of the bottles' box, and it is Middlecamp who shoots the orc dummy, turns to the paper target and shoots from the hip at the bottles.

## dun-morogh-fluffy
At the ranch on the road east, where a family raises rams,
the youngest has spent all day chasing someone small and white
who wants no part of what she has in mind.
Ease its fright before it runs off again.
? Amberstill Ranch, by the road to Loch Modan: the girl, and what she is chasing. Soothe the little animal the girl is chasing.
= Fluffy, a rabbit, and Yarlyn Amberstill, who runs after it round the ram pen, calling: 'C'mon Fluffy! I just want to give you a bath!'
+ Her other offers, in Dwarvish: 'Carrots every day for a year if you stop!' And, when that fails: 'Don't make me get my pappy to catch you! He likes to catch bunnies using his rifle!'

## quarry
On the island in the middle of the frozen lake to the north-west,
a white wolf leads the pack, with two starving wolves at his heels.
Bring him into a fight and he will bring others.
Thin the island first.
= Timber, a white wolf, and very likely the alpha of Iceflow Lake's pack. He alone carries the Silver-lined Bracers and the White Wolf Gloves.
+ He walks at level ten, when a hunter first learns to tame: a dwarf or a gnome can take him as a first companion.
