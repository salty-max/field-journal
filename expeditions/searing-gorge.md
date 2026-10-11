---
zone: 1427   # Searing Gorge
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
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
quarry:
  id: 14621
  sources: "quests 7701 (Overseer Oilfist's poster), 7722 (Master Smith Burninate)"
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

## quarry
An agent of the Thorium Brotherhood went back to the Dark Irons,
and his old clan believes he took the secret of its fiery flux as his price.
They made him overseer of the crew that works the Slag Pit.
His brothers have posted his head: look deep inside the pit.
= Overseer Maltorius. Lookout Captain Lolo Longstriker pays the bounty; Master Smith Burninate wants the flux plans back.
+ Lolo had not thought to see that ugly mug again: it looks better, Lolo says, without the rest of him attached.
