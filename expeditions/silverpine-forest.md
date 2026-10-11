---
zone: 1421   # Silverpine Forest
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: silverpine-forest-near
    tier: near
    object: 1593   # dump 58.4, 34.9; Wowhead 58.4, 34.9
    hint_area: { x: 58.7, y: 38.9, r: 8 }
    danger: "Guarded (Rot Hide gnolls, the dead)"
    sources: "quests 438, 439"
  - id: silverpine-forest-off
    tier: off
    area: The Ivar Patch   # placed: Ivar the Foul, dump 51.5, 13.9; Wowhead 51.4, 13.8
    hint_area: { x: 53.8, y: 11.3, r: 7 }
    danger: "Guarded (Ivar the Foul)"
    sources: "quest 425; Ivar the Foul (creature 1971) places the hint"
  - id: silverpine-forest-hidden
    tier: hidden
    object: 1599   # dump 67.9, 24.9; Wowhead 67.8, 24.8
    hint_area: { x: 71.5, y: 26.7, r: 8 }
    danger: "Perilous (Fenris Keep's dead and gnolls)"
    sources: "quests 460, 461"
# quarry: the zone's own, in the hunts' pass
---
## silverpine-forest-near
At a ferry no one crosses any more,
a boat is heaped with the wrapped dead,
and one hand wears a ring engraved for someone.
Find the boat, and look across the water.
? The Decrepit Ferry, on the lake shore east of the Sepulcher.
= The ring reads 'For Deliah'. Across the water, a dock on Fenris Isle.
+ The woman was recently killed, and the only such bodies nearby are in Tirisfal's mass graves: the Rot Hide gnolls are carrying them to Fenris Isle.

## silverpine-forest-off
In the far north of the pines, a farm and a ghoul share a name.
He waits in his barn for the guard to drop,
and two scouts of the Forsaken have learned what he does when it does.
Find his patch.
? North of the Sepulcher, near the coast, a pumpkin patch with a keeper.
= The Ivar Patch. Rane and Quinn Yorick came to scout the forest and got no further.
+ 'If you won't do it for me and my brother, then do it for the Forsaken.' Rane Yorick, guarding Quinn while he heals.

## silverpine-forest-hidden
On the island in the lake, near the keep's old stable,
a servant's body lies in an unmarked grave without its head.
His master's spell kept the plague from him, and death with it;
the gnolls dug the grave. Find it.
? Fenris Isle, in Lordamere Lake: near the keep's stable.
= Alaric, Thule Ravenclaw's head servant. His head is with the gnolls. He asks to be put back together, and to be spared his boots: they never fit.
+ He would rather rest in the keep's hidden alcove: 'I spent the best days of my life in this keep.'
