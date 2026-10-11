---
zone: 1448   # Felwood
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: felwood-emerald-sanctuary
    tier: near
    area: Emerald Sanctuary   # placed: the client's overlay: 51.6, 79.7, half-size 4.7 by 4.1
    hint_area: { x: 50.0, y: 78.0, r: 7 }
    danger: "Quiet"
    sources: "the Codex's emerald-sanctuary page"
  - id: felwood-arkonarin
    tier: off
    creature: 11016   # Captured Arko'narin, dump 36.2, 55.5; Wowhead 36.2, 55.4 (she walks only when escorted)
    hint_area: { x: 36.6, y: 58.0, r: 5 }
    danger: "Perilous (the Shadow Council)"
    sources: "quests 5203, 5204"
  - id: felwood-trey-lightforge
    tier: hidden
    gestures: [KNEEL, MOURN, PRAY]
    creature: 11020   # the Remains of Trey Lightforge, dump 38.5, 50.4; Wowhead 38.4, 50.4
    hint_area: { x: 36.2, y: 51.3, r: 5 }
    danger: "Perilous"
    sources: "quests 5204, 5385, 5203"
  - id: felwood-talonbranch
    tier: town
    faction: alliance   # its town's: for that faction alone
    object: 174594   # dump 63.3, 22.6; Wowhead 63.3, 22.6
    hint_area: { x: 60.6, y: 25.6, r: 8 }
    danger: "Quiet"
    sources: "quest 2878; the Codex's talonbranch-glade page"
  - id: felwood-bloodvenom
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 9620   # Dreka'Sur, dump 34.8, 52.7; Wowhead 34.8, 52.6
    hint_area: { x: 33.4, y: 54.7, r: 5 }
    danger: "Quiet"
    sources: "quest 6162; the Codex's bloodvenom-post page"
# quarry: the zone's own, in the hunts' pass
---
## felwood-emerald-sanctuary
In the south of the poisoned forest, a grove of druids
has sworn to heal the land the demons fouled,
one tree, one spring, one flower at a time. Find their grove.
? The Emerald Sanctuary, in the south of Felwood, by the road.
= The Emerald Sanctuary, held by the Emerald Circle.
+ They fight the Jadefire satyrs and the Shadow Council, and study the blood amber of the corrupted ancients.

## felwood-arkonarin
In the warlocks' hold among the old ruins of the west,
a Sentinel lies captive, who heard her friend tortured to death,
and still means to carry his sword home. Find her.
? Shadow Hold, in Jaedenar, in the west of Felwood.
= Arko'narin, captive of the Shadow Council.
+ She would not even stop to be healed on her way to Darnassus with the sword Lightforge: 'She said it was far too urgent.'

## felwood-trey-lightforge
A knight of the old order came into the poisoned forest
and was tortured by a demon until his spirit was all that was left.
His friends want him given the respect he is owed. Find what remains of him.
? By the Bloodvenom Falls, in Felwood.
= The remains of Trey Lightforge, a Knight of the Silver Hand.
+ 'What a terrible fate for a Knight of the Silver Hand.' At least his spirit has been released from any pain that might have been forced upon him.

## felwood-talonbranch
Beside the night elves' glade in the north of the poisoned forest,
a flower the corruption took can be made to bloom again,
with the right salve from the druids. Find it.
? Talonbranch Glade.
= A corrupted songflower at Talonbranch Glade.
+ With a little Cenarion plant salve, it 'immediately begins to shed its corrupted form, blossoming into a vibrant and healthy plant.'

## felwood-bloodvenom
In the Horde's camp beside the poisoned falls, a widow
whose husband went into the forest with a druid against a great furbolg
waits for the beast to pay for her life alone. Find her.
? Bloodvenom Post.
= Dreka'Sur, widow of the Bloodvenom Post.
+ 'My husband died in battle--he would have been proud of that. But I could not rest until I knew that the creature that has forced me to live my life alone paid for what it had done.'
