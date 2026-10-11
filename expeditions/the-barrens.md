---
zone: 1413   # The Barrens
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: the-barrens-ratchet-book
    tier: near
    reading: Exile of the High Elves
    object: 175731   # dump 61.9, 38.7; Wowhead 62.0, 38.7
    hint_area: { x: 63.4, y: 42.4, r: 8 }
    danger: "Quiet"
    sources: "object 175731's text"
  - id: the-barrens-mankriks-wife
    tier: near
    gestures: [MOURN, KNEEL, CRY]
    creature: 10668   # the Beaten Corpse, dump 49.3, 50.3; Wowhead 49.2, 50.4
    hint_area: { x: 51.5, y: 52.3, r: 6 }
    danger: "Guarded (quilboar)"
    sources: "quests 4921, 899"
  - id: the-barrens-forgotten-pools
    tier: off
    name: The Forgotten Pools
    trigger: 216   # the quest's exploration trigger (AreaTrigger 216, radius 9 yards): 45.1, 22.5
    hint_area: { x: 48.7, y: 24.3, r: 8 }
    danger: "Guarded (the Kolkar)"
    sources: "quests 870, 877; the client's AreaTrigger 216"
  - id: the-barrens-dry-hills
    tier: off
    area: The Dry Hills   # placed: the client's overlay: 39.7, 14.6, half-size 4.7 by 5.6
    hint_area: { x: 41.5, y: 16.0, r: 8 }
    danger: "Guarded (the Witchwing harpies)"
    sources: "quests 875, 876"
  - id: the-barrens-mahren
    tier: off
    creature: 3388   # Mahren Skyseer, dump 65.8, 43.9; Wowhead 65.8, 43.8
    hint_area: { x: 62.9, y: 44.8, r: 6 }
    danger: "Quiet on the shore; perilous in the water"
    sources: "quests 873, 874"
  - id: the-barrens-fallen-warrior
    tier: hidden
    gestures: [SALUTE, BOW]
    area: Shrine of the Fallen Warrior   # placed: Koiter, dump 47.4, 29.7; Wowhead 47.4, 29.6
    anchor: { creature: 12034 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 49.9, y: 28.1, r: 6 }
    danger: "Quiet"
    sources: "the wiki's Shrine of the Fallen Warrior; Koiter (creature 12034) places the hint"
  - id: the-barrens-dogran
    tier: hidden
    creature: 5908   # Grunt Dogran, dump 43.3, 47.9; Wowhead 43.2, 47.8
    hint_area: { x: 43.5, y: 50.9, r: 6 }
    danger: "Perilous (the quilboar camp)"
    sources: "quests 1509, 1510, 1515, 1512"
  - id: the-barrens-crossroads
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [COMFORT, SOOTHE]
    creature: 3432   # Mankrik, dump 52.0, 31.6; Wowhead 52.0, 31.6
    hint_area: { x: 53.9, y: 33.3, r: 5 }
    danger: "Quiet"
    sources: "quests 899, 4921"
  - id: the-barrens-taurajo
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [PITY]
    creature: 3430   # Mangletooth, dump 44.5, 59.3; Wowhead 44.4, 59.2
    hint_area: { x: 45.9, y: 61.3, r: 5 }
    danger: "Quiet"
    sources: "quests 878, 879"
quarry:
  id: 3474
  sources: "quest 883 (the hoof's own words, Jorn Skyseer); the dump's four spawn points"
---
## the-barrens-ratchet-book
In the goblins' port, where every side may trade,
a history tells of the elves who would not give up their magic,
were banished for the storm they called down,
and sailed away to found a kingdom in the sun.
? Ratchet, on the Barrens' coast.
= Exile of the High Elves, in Ratchet. The goblins keep a history of elves; it is not for sale.
+ Dath'Remar mocked the druids as cowards. They could not bring themselves to put so many of their kin to death, and exiled them instead.

## the-barrens-mankriks-wife
South of the crossroads, by the gold road, in a small tauren camp,
a woman held three of the boar men off by herself
until more came. Her husband woke on the road, tended by a stranger,
and has watched the horizon ever since. Find her.
? South of the Crossroads, near the Gold Road, a camp the quilboar overran.
= Mankrik's wife. He stands at the Crossroads every day, from sunrise to dusk, scanning the horizon.
+ 'The pain in my chest tells me that the worst has happened, but I have hope you will find her safe and sound.' He has killed every quilboar he has met since.

## the-barrens-forgotten-pools
North-west of the crossroads, a pool came back to the dry land,
and the druids felt a power leaking up from deep below.
Go down into its waters, to where the earth breathes.
? The Forgotten Pools, north-west of the Crossroads: the answer is under the water.
= A fissure in the earth at the bottom of the Forgotten Pools, gases bubbling from it.
+ Tonga Runetotem believes the new oases formed within the past few years, fed by such fissures.

## the-barrens-dry-hills
In the north-western hills the harpies raid the caravans
for a sister's sake: a beastmaster slew her long ago,
and the sister who leads them now has not forgotten.
Find the hills where they nest.
? North-west of the Crossroads, the Witchwing harpies hold the foothills of Stonetalon.
= The Dry Hills. Serena Bloodfeather's sister fell to Rexxar; the caravans pay for it.
+ Darsok Swiftdagger of the Crossroads wants Serena's head on the next caravan he sends out.

## the-barrens-mahren
On the coast the humans hold, a huntress of the plains
stalks the lord of these waters, a giant that has eaten many of them.
She does not fear him; she is grateful he is there.
Find her on the shore.
? The Merchant Coast, south of Ratchet.
= Mahren Skyseer, Jorn Skyseer's sister, who hunts Isha Awak, the Deep Doom.
+ 'His spirit dwells in his heart, and to hear its beat is to know your fate.'

## the-barrens-fallen-warrior
Not far from the busiest road of the plains, a short trail climbs a hill
to a shrine raised for a warrior who fell,
and a spirit healer waits before it, as if for him.
Few find it. Honour him as one warrior honours another.
? West of the Crossroads, follow a ridge up a small hill.
= The Shrine of the Fallen Warrior, and its own spirit healer, Koiter.
+ It remembers Michel Koiter, who worked on this world and died before it was finished; the spirit healer bears his name, and the orc of the shrine was his own character.

## the-barrens-dogran
In a quilboar camp of two huts, under heavy guard,
a grunt sent proudly to the crossroads lies wounded and a prisoner.
His mate in the city has had no word,
and he will have something to ask of whoever reaches him. Find him.
? Agama'gor, north of Camp Taurajo: look for a group of two huts.
= Grunt Dogran. He will keep his life, not his leg or his arm.
+ He sends back his pendant and asks that his mate never learn why: 'Zankaja is young and beautiful. To be chained to an invalid... I will not allow her to suffer that injustice.'

## the-barrens-crossroads
In the town where the plains' roads meet, a warrior stands every day
from sunrise to dusk, watching the horizon,
and kills every boar man who crosses his path.
Find him, and be gentle.
? The Crossroads.
= Mankrik. His wife fell in a small tauren camp to the south.
+ 'Perhaps instead of heading north to the Crossroads I should have headed to Taurajo.'

## the-barrens-taurajo
In the tauren camp in the south, a boar man sits in a cage.
He helps the Horde against his own tribe's enemies,
and his own tribe has left him to rot. Find his cage,
and feel for him what his tribe does not.
? Camp Taurajo.
= Mangletooth, of the Razormane. He trades blessings of Agamaggan for blood shards.
+ 'They should have made sure I was dead when they turned their backs on me instead of leaving me here in this forsaken cage.'

## quarry
Among the kodos of the plains walks one greater than the rest.
The tauren call him by a name that means the earth shakes,
for his steps are like gathered thunder.
He roams the grass between the thorn-wrapped hill and the bramble scar.
= Lakota'mani. His hoof, a symbol of the great kodo's strength, goes to Jorn Skyseer at Camp Taurajo.
+ Jorn names whoever brings it Earthshaker too: walk tall, he says, for the kodo's courage goes with you now.
