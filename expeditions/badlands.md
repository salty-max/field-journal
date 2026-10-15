---
zone: 1418   # Badlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: badlands-apocryphans-rest
    tier: off
    gestures: [GAZE, AWE, AMAZE, PONDER, THINK, LOOK, PEER, STARE]
    area: Apocryphan's Rest   # placed: the client's overlay: 15.7, 61.8, half-size 5.7 by 7.9
    hint_area: { x: 16.0, y: 60.0, r: 8 }
    danger: "Guarded (giant buzzards, coyotes and ridge stalkers, levels 39 and 40)"
    sources: "the WoWWiki archive's Apocryphan's Rest and Badlands pages; the dump's spawns"
quarry:
  id: 2850   # Broken Tooth
  sources: "the WoWWiki archive's Broken Tooth page (asleep in the sun; the quickest claws); the dump's spawns; https://www.wow-petopia.com/classic/attackspeed.php (Classic's fastest cat)"
---
## badlands-apocryphans-rest
South of the Horde's stockade on the western cliffs,
something died that was bigger than a keep, and it lies where it fell:
a cage of ribs the vultures have long since picked clean.
It has a name on the maps, and nothing more. Take in what remains among its bones.
? South of Kargath, on the Badlands' western side. Among the bones, look at how big they are.
= Apocryphan's Rest: the skeleton of a dragon, south of Kargath. Whose bones they were, nobody in the Badlands says.
+ The black dragonflight still keeps a ravine of its own, at the waste's far eastern edge.

## quarry
In the north of the waste, a cougar with a broken fang
lies about in the sun, and seems to be asleep.
His stillness is a poor guide to the speed of his claws.
= Broken Tooth, a cougar of the Badlands, sunning himself in the north, around Angor Fortress and Hammertoe's Digsite and up to the Maker's Terrace.
+ Tamed, he keeps the speed of those claws, which makes him a prize among hunters.
