---
zone: 1427   # Searing Gorge
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: searing-gorge-cauldron
    tier: near
    area: The Cauldron   # placed: the client's overlay: 46.2, 49.4, half-size 14.7 by 10.5
    hint_area: { x: 44.0, y: 51.0, r: 13 }
    danger: "Perilous (Dark Irons, golems)"
    sources: "the Codex's the-cauldron page"
  - id: searing-gorge-suntara
    tier: hidden
    object: 148498   # dump 41.3, 25.4; Wowhead 41.3, 25.6; the Dying Archaeologist beside it
    hint_area: { x: 42.4, y: 29.2, r: 8 }
    danger: "Perilous (the Twilight's Hammer)"
    sources: "quests 3372, 3371"
# quarry: the zone's own, in the hunts' pass
---
## searing-gorge-cauldron
In a basin of ash, dwarves of dark iron work a great pit
with golems and slaves, in heat that drives the slaves mad,
so mad they strike at those who would free them. Look down into it.
? The Cauldron, in the middle of the Searing Gorge.
= The Cauldron, the Dark Irons' great mining pit.
+ Beneath it, Overseer Maltorius commands the Slag Pit, back with the masters he once left.

## searing-gorge-suntara
By an altar in the north-west hills, a digger from a lost expedition lies dying.
Even after their bodies give out, a power forces his comrades to keep working,
and he asks only that they be released.
Find the altar.
? In the hills north-west of the Cauldron, where the Twilight's Hammer guard a relic.
= The Altar of Suntara, and the dying archaeologist beside it.
+ Dorius led the expedition, and did not survive it; his last wish, carried home by a friend with 'an empty, vacuous hole' where a heart used to be, was that his men be freed.
